from flask import Flask, jsonify, send_from_directory, request
import os
import json

app = Flask(__name__)

SORTED_FOLDER = r"C:\Users\Admin\Desktop\rangmahal (2)\rangmahal\server_code\data\sorted_data"

def fetch_images_with_discount(genders, articles, discount):
    if not genders or not articles:
        return {"error": "Missing parameters"}, 400

    gender_list = genders.split(",")  # Convert CSV to list
    article_list = articles.split(",")

    image_data = []

    for gender in gender_list:
        for article in article_list:
            article_path = os.path.join(SORTED_FOLDER, gender.strip(), article.strip())

            if not os.path.exists(article_path):
                continue  # Skip if folder doesn't exist

            for file in os.listdir(article_path):
                if file.endswith(('.jpg', '.png')):
                    img_name = os.path.splitext(file)[0]
                    json_file = os.path.join(article_path, f"{img_name}.json")

                    product_data = {}
                    if os.path.exists(json_file):
                        with open(json_file, 'r', encoding='utf-8') as f:
                            json_content = json.load(f)
                            original_price = json_content.get("data", {}).get("price", "N/A")

                            if original_price != "N/A":
                                try:
                                    original_price = float(original_price)
                                    discounted_price = int(original_price * (1 - discount))  # Convert to int
                                except ValueError:
                                    discounted_price = "N/A"
                            else:
                                discounted_price = "N/A"

                            # Fetch baseColour if available
                            base_colour = json_content.get("data", {}).get("baseColour", "Unknown")

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
                                "price": original_price,
                                "discountedPrice": discounted_price,
                                "productName": json_content.get("data", {}).get("productDisplayName", "Unknown"),
                                "brand": json_content.get("data", {}).get("brandName", "Unknown"),
                                "baseColour": base_colour,  # Include baseColour in response
                                "styleImages": style_images  # ✅ Added field
                            }

                    server_host = request.host
                    image_data.append({
                        "image_url": f"http://{server_host}/images/{gender}/{article}/{file}",
                        "product_info": product_data
                    })

    return {"images": image_data}


@app.route('/get_images', methods=['GET'])
def get_images_with_50_discount():
    genders = request.args.get("genders", "")  
    articles = request.args.get("articles", "")
    return jsonify(fetch_images_with_discount(genders, articles, 0.5))

@app.route('/get_images_20', methods=['GET'])
def get_images_with_20_discount():
    genders = request.args.get("genders", "")  
    articles = request.args.get("articles", "")
    return jsonify(fetch_images_with_discount(genders, articles, 0.2))

@app.route('/get_images_30', methods=['GET'])
def get_images_with_30_discount():
    genders = request.args.get("genders", "")  
    articles = request.args.get("articles", "")
    return jsonify(fetch_images_with_discount(genders, articles, 0.3))

@app.route('/get_images_40', methods=['GET'])
def get_images_with_40_discount():
    genders = request.args.get("genders", "")  
    articles = request.args.get("articles", "")
    return jsonify(fetch_images_with_discount(genders, articles, 0.4))

@app.route('/images/<gender>/<article>/<filename>')
def get_image(gender, article, filename):
    image_path = os.path.join(SORTED_FOLDER, gender, article)
    if not os.path.exists(os.path.join(image_path, filename)):
        return jsonify({"error": "Image not found"}), 404
    return send_from_directory(image_path, filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
