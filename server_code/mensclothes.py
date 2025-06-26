from flask import Flask, jsonify, send_from_directory, request
import os
import json

app = Flask(__name__)

# ✅ Set absolute path for your image & JSON folder
SORTED_FOLDER = r"C:\Users\Admin\Desktop\rangmahal\server_code\data\sorted_data"

@app.route('/get_images/<gender>/<article>', methods=['GET'])
def get_images(gender, article):
    article_path = os.path.join(SORTED_FOLDER, gender, article)

    # ✅ Debug: Check if folder exists
    if not os.path.exists(article_path):
        return jsonify({"error": f"Path '{article_path}' not found!"}), 404

    # ✅ Get images and corresponding JSON data
    image_data = []
    for file in os.listdir(article_path):
        if file.endswith(('.jpg', '.png')):  # ✅ Only image files
            img_name = os.path.splitext(file)[0]  # Remove extension
            json_file = os.path.join(article_path, f"{img_name}.json")

            # ✅ Read JSON file if exists
            product_data = {}
            if os.path.exists(json_file):
                with open(json_file, 'r', encoding='utf-8') as f:
                    json_content = json.load(f)

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
                        "discountedPrice": json_content.get("data", {}).get("discountedPrice", "N/A"),
                        "productName": json_content.get("data", {}).get("productDisplayName", "Unknown"),
                        "brand": json_content.get("data", {}).get("brandName", "Unknown"),
                        "styleImages": style_images  # ✅ Added field
                    }

            # ✅ Get server IP dynamically for accessible image URLs
            server_host = request.host  # This includes IP + port

            # ✅ Add image URL + JSON details
            image_data.append({
                "image_url": f"http://{server_host}/images/{gender}/{article}/{file}",
                "product_info": product_data
            })

    return jsonify({"images": image_data})

# ✅ Route to serve images
@app.route('/images/<gender>/<article>/<filename>')
def get_image(gender, article, filename):
    image_path = os.path.join(SORTED_FOLDER, gender, article)
    return send_from_directory(image_path, filename)

# ✅ Run Flask on all network interfaces
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
