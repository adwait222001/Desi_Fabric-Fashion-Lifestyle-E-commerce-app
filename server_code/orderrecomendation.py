from flask import Flask, request, jsonify, send_from_directory
import os
import json
import pandas as pd
import sqlite3
import re

app = Flask(__name__)

# === Config ===
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SORTED_FOLDER = r"C:\Users\Admin\Desktop\rangmahal (2)\rangmahal\server_code\data\sorted_data"
ORDER_DB = os.path.join(BASE_DIR, 'order_data.db')
HISTORY_DB = os.path.join(BASE_DIR, 'orderhistory.db')

# === Helper: Normalize words ===
def normalize(word):
    word = re.sub(r'[^a-zA-Z]', '', word).lower().strip()
    if word.endswith('s') and not word.endswith('ss'):
        word = word[:-1]
    return word

# === Folder Mapping: e.g., 'tshirt' → 'Tshirts' ===
folder_map = {"men": {}, "women": {}}
for gender in ["men", "women"]:
    gender_path = os.path.join(SORTED_FOLDER, gender)
    if not os.path.isdir(gender_path):
        continue
    for folder in os.listdir(gender_path):
        full_path = os.path.join(gender_path, folder)
        if os.path.isdir(full_path):
            norm = normalize(folder)
            folder_map[gender][norm] = folder

print("📁 Folder map built:", folder_map)

# === Manual corrections for typos/variants ===
manual_map = {
    "sare": "saree",
    "shirt": "tshirt",
    "tshirts": "tshirt",
    "kurta": "traditional",
    "pant": "formal",
    "shoe": "shoe",
    "dresse": "dress"
}

# === Parse Ordered Items from DB ===
def parse_ordered_items(user_id):
    def fetch_items(db_path, table):
        items = []
        if not os.path.exists(db_path):
            print(f"⚠️ DB not found: {db_path}")
            return items
        try:
            with sqlite3.connect(db_path) as conn:
                cursor = conn.cursor()
                cursor.execute(f"SELECT items FROM {table} WHERE user_id = ?", (user_id,))
                rows = cursor.fetchall()
                for row in rows:
                    try:
                        parsed = json.loads(row[0])
                        for entry in parsed:
                            if isinstance(entry, dict) and 'productName' in entry:
                                name = entry['productName']
                                last_word = normalize(name.split()[-1])
                                last_word = manual_map.get(last_word, last_word)

                                for gender in folder_map:
                                    if last_word in folder_map[gender]:
                                        print(f"✅ Match: '{name}' → {last_word}")
                                        items.append((last_word, gender))
                                        break
                                else:
                                    print(f"❌ No folder match: {name} → {last_word}")
                    except Exception as e:
                        print(f"⚠️ JSON parse error: {e}")
        except Exception as e:
            print(f"❌ DB read error: {e}")
        return items

    all_items = fetch_items(ORDER_DB, "orders") + fetch_items(HISTORY_DB, "order_history")
    return list(set(all_items))  # Remove duplicates

# === Recommend by walking folders ===
def recommend_from_folder(article_norm, gender):
    if article_norm not in folder_map[gender]:
        return []

    article_folder = folder_map[gender][article_norm]
    folder_path = os.path.join(SORTED_FOLDER, gender, article_folder)
    results = []

    if not os.path.isdir(folder_path):
        return []

    seen = set()
    for file in os.listdir(folder_path):
        if file.lower().endswith(('.jpg', '.png')):
            image_base = os.path.splitext(file)[0]
            if image_base in seen:
                continue
            seen.add(image_base)

            image_file = os.path.join(folder_path, image_base + '.jpg')
            if not os.path.exists(image_file):
                image_file = os.path.join(folder_path, image_base + '.png')
                if not os.path.exists(image_file):
                    continue

            json_file = os.path.join(folder_path, image_base + '.json')
            product_data = {}
            style_images = []

            if os.path.exists(json_file):
                try:
                    with open(json_file, 'r', encoding='utf-8') as f:
                        content = json.load(f)
                        data = content.get("data", {})
                        product_data = {
                            "price": data.get("price", "N/A"),
                            "discountedPrice": data.get("discountedPrice", "N/A"),
                            "productName": data.get("productDisplayName", "Unknown"),
                            "brand": data.get("brandName", "Unknown"),
                        }
                        for key, val in data.get("styleImages", {}).items():
                            if val.get("imageURL"):
                                style_images.append({
                                    "type": key,
                                    "url": val["imageURL"]
                                })
                except Exception as e:
                    print(f"⚠️ Error reading JSON for {image_base}: {e}")

            result = {
                "image_name": image_base,
                "gender": gender,
                "image_url": f"http://192.168.29.214:5000/images/{gender}/{article_folder}/{image_base}.jpg",
                "product_info": product_data,
                "styleImages": style_images
            }

            results.append(result)

            if len(results) >= 3:
                break

    return results

# === API Endpoint ===
@app.route('/recommend_from_itemstring', methods=['GET'])
def recommend_from_itemstring():
    user_id = request.args.get("user_id")
    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400

    parsed_items = parse_ordered_items(user_id)
    print(f"🎯 Extracted: {parsed_items}")

    all_recommendations = []
    for article_norm, gender in parsed_items:
        recs = recommend_from_folder(article_norm, gender)
        all_recommendations.extend(recs)

    return jsonify({"recommended": all_recommendations})

# === Static Image Server ===
@app.route('/images/<gender>/<article>/<filename>')
def serve_image(gender, article, filename):
    path = os.path.join(SORTED_FOLDER, gender, article)
    return send_from_directory(path, filename)

# === Run App ===
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
