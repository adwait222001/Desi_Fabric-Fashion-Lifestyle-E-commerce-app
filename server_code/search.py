from flask import Flask, jsonify, request, send_from_directory
import os
import json
from fuzzywuzzy import process

app = Flask(__name__)

# Path to your sorted data folder
SORTED_FOLDER = r"C:\Users\Admin\Desktop\rangmahal (2)\rangmahal\server_code\data\sorted_data"

PRODUCTS = []
GENDERS = set()
ARTICLES = set()


# ---------- Load Products From Folder ----------
def load_all_products():
    all_products = []
    genders = set()
    articles = set()

    for gender in os.listdir(SORTED_FOLDER):
        gender_path = os.path.join(SORTED_FOLDER, gender)
        if not os.path.isdir(gender_path):
            continue
        genders.add(gender.lower())

        for article in os.listdir(gender_path):
            article_path = os.path.join(gender_path, article)
            if not os.path.isdir(article_path):
                continue
            articles.add(article.lower())

            for file in os.listdir(article_path):
                if file.endswith(".json"):
                    try:
                        with open(os.path.join(article_path, file), "r", encoding="utf-8") as f:
                            data = json.load(f).get("data", {})

                        product_name = data.get("productDisplayName", "Unknown")
                        brand = data.get("brandName", "Unknown")
                        base_colour = data.get("baseColour", "Unknown")
                        price = data.get("price", "N/A")

                        # Extract styleImages URLs
                        style_images = []
                        style_images_dict = data.get("styleImages", {})
                        for style_key in ["front", "back", "left", "right", "default"]:
                            img_data = style_images_dict.get(style_key, {})
                            img_url = img_data.get("imageURL")
                            if img_url:
                                style_images.append({"type": style_key, "url": img_url})

                        # Build product entry
                        product_entry = {
                            "gender": gender,
                            "article": article,
                            "productName": product_name,
                            "brand": brand,
                            "baseColour": base_colour,
                            "price": price,
                            "styleImages": style_images,
                            "localImage": file.replace(".json", ".jpg")  # assuming JPG images
                        }
                        all_products.append(product_entry)

                    except Exception as e:
                        print(f"Error loading {file}: {e}")

    return all_products, genders, articles


PRODUCTS, GENDERS, ARTICLES = load_all_products()


# ---------- Helper for Partial Matching ----------
def partial_match(word, collection):
    word = word.lower()
    for item in collection:
        if item == word or item.startswith(word) or word in item:
            return item
    return None


# ---------- Search Logic ----------
def match_products_logic(query):
    query = query.strip()
    if not query:
        return {"error": "Missing 'query' parameter"}

    words = query.lower().split()

    found_gender = None
    found_article = None

    # Try to detect gender & article from folder names
    for word in words:
        if not found_gender:
            match = partial_match(word, GENDERS)
            if match:
                found_gender = match
        if not found_article:
            match = partial_match(word, ARTICLES)
            if match:
                found_article = match

    # Case 1: Gender + Article found
    if found_gender and found_article:
        matches = [
            p for p in PRODUCTS
            if p["gender"].lower() == found_gender and p["article"].lower() == found_article
        ]
        return {"queryType": "category+gender", "results": matches}

    # Case 2: Only Article found
    if found_article:
        matches = [p for p in PRODUCTS if p["article"].lower() == found_article]
        return {"queryType": "category", "results": matches}

    # Case 3: Only Gender found
    if found_gender:
        matches = [p for p in PRODUCTS if p["gender"].lower() == found_gender]
        return {"queryType": "gender", "results": matches}

    # Case 4: Fuzzy match product names
    product_names = [p["productName"] for p in PRODUCTS]
    fuzzy_matches = process.extract(query, product_names, limit=10)

    results = []
    for match_name, score in fuzzy_matches:
        if score < 60:
            continue
        for p in PRODUCTS:
            if p["productName"] == match_name:
                results.append(p)

    return {"queryType": "fuzzy", "results": results}


# ---------- API Endpoint ----------
@app.route("/match_products", methods=["GET"])
def match_products_api():
    query = request.args.get("query", "").strip()
    result = match_products_logic(query)
    return jsonify(result)


# ---------- Serve Local Images ----------
@app.route("/images/<gender>/<article>/<filename>")
def get_image(gender, article, filename):
    image_path = os.path.join(SORTED_FOLDER, gender, article)
    return send_from_directory(image_path, filename)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
