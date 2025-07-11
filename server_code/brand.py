from flask import Flask, jsonify, send_from_directory, request
import os
import json

app = Flask(__name__)

SORTED_FOLDER = r"C:\Users\Admin\Desktop\rangmahal (2)\rangmahal\server_code\data\sorted_data"
def fetch_images_by_brand(genders, articles, brand):
    if not genders or not articles or not brand:
        return {"error": "Missing parameters"}, 400

    gender_list = [g.strip() for g in genders.split(",")]  # Remove extra spaces
    article_list = [a.strip() for a in articles.split(",")]
    brand_lower = brand.strip().lower()
    brand_upper = brand.strip().upper()

    image_data = []

    for gender in gender_list:  # Iterate over multiple genders
        for article in article_list:  # Iterate over multiple articles
            article_path = os.path.join(SORTED_FOLDER, gender, article)

            if not os.path.exists(article_path):
                continue  

            for file in os.listdir(article_path):
                if file.endswith(('.jpg', '.png')):
                    img_name = os.path.splitext(file)[0]
                    json_file = os.path.join(article_path, f"{img_name}.json")

                    if os.path.exists(json_file):
                        with open(json_file, 'r', encoding='utf-8') as f:
                            json_content = json.load(f)
                            product_brand = json_content.get("data", {}).get("brandName", "").strip()

                            print(f"Checking: {json_file} | Found brand: {product_brand}")  # Debugging

                            if product_brand.lower() == brand_lower or product_brand.upper() == brand_upper:
                                print(f"✔ Match Found: {product_brand}")

                                # ✅ Extract styleImages array
                                style_images = []
                                style_images_dict = json_content.get("data", {}).get("styleImages", {})
                                for style_key in ["front", "back", "left", "right", "default"]:
                                    img_data = style_images_dict.get(style_key, {})
                                    img_url = img_data.get("imageURL")
                                    if img_url:
                                        style_images.append({
                                            "type": style_key,
                                            "url": img_url
                                        })

                                product_data = {
                                    "price": json_content.get("data", {}).get("price", "N/A"),
                                    "productName": json_content.get("data", {}).get("productDisplayName", "Unknown"),
                                    "brand": product_brand,
                                    "baseColour": json_content.get("data", {}).get("baseColour", "Unknown"),
                                    "styleImages": style_images  # ✅ Added field
                                }

                                server_host = request.host
                                image_data.append({
                                    "image_url": f"http://{server_host}/images/{gender}/{article}/{file}",
                                    "product_info": product_data
                                })

    return {"images": image_data}


@app.route('/get_images_by_brand', methods=['GET'])
def get_images_by_brand():
    genders = request.args.get("genders", "")  
    articles = request.args.get("articles", "")
    brand = request.args.get("brand", "")
    return jsonify(fetch_images_by_brand(genders, articles, brand))


@app.route('/images/<gender>/<article>/<filename>')
def get_image(gender, article, filename):
    image_path = os.path.join(SORTED_FOLDER, gender, article)
    if not os.path.exists(os.path.join(image_path, filename)):
        return jsonify({"error": "Image not found"}), 404
    return send_from_directory(image_path, filename)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
