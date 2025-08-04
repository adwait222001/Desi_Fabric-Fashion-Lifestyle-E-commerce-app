from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import os

# Module imports
from image_upload import handle_files, fetch_image
from profile_name import add_name, init_db, show_name
from multiple import fetch_images_with_discount
from samecolour import fetch_images_with_matching_colour
from brand import fetch_images_by_brand
from orderbase import (
    init_order_db,
    add_order,
    get_orders,
    archive_expired_orders,
    get_archived_orders
)
from apscheduler.schedulers.background import BackgroundScheduler
from recommendsystem import recommend_tshirt, get_image_info
from orderrecomendation import parse_ordered_items, recommend_from_folder
#new import


from recommendsystemb import recommend_tshirt_no_brand, get_image_info





app = Flask(__name__)
CORS(app)

# Initialize databases
init_db()
init_order_db()

# Background task to archive expired orders
scheduler = BackgroundScheduler()
scheduler.add_job(archive_expired_orders, 'interval', seconds=30)
scheduler.start()

# ✅ Upload image route
@app.route('/image', methods=['POST'])
def senddata():
    try:
        if 'file' not in request.files or 'user_id' not in request.form:
            return jsonify({'message': 'File and user_id are required'}), 400

        image_file = request.files['file']
        user_id = request.form['user_id']

        if image_file.filename == '':
            return jsonify({'message': 'No selected file'}), 400

        filename = handle_files(image_file, user_id)
        return jsonify({'message': f'File uploaded successfully as {filename}'}), 200

    except Exception as e:
        return jsonify({'message': 'File upload failed', 'error': str(e)}), 500

# ✅ Add user profile name
@app.route('/add', methods=['POST'])
def add_name_route():
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        name = data.get('name')

        if not user_id or not name:
            return jsonify({"message": "user_id and name are required"}), 400

        add_name(user_id, name)
        return jsonify({'message': 'Name uploaded successfully'}), 200

    except Exception as e:
        return jsonify({'message': 'Name upload failed', 'error': str(e)}), 500

# ✅ Show profile name
@app.route('/cat', methods=['POST'])
def show_profile_name():
    try:
        data = request.get_json()
        user_id = data.get('user_id')
        if not user_id:
            return jsonify({"message": "User ID is required"}), 400
        return show_name(user_id=user_id)
    except Exception as e:
        return jsonify({"message": f"Error: {str(e)}"}), 500

# ✅ Get image by user ID
@app.route('/test/<user_id>', methods=['GET'], endpoint='get_image_route')
def get_image_by_user(user_id):
    try:
        return fetch_image(user_id)
    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

# ✅ Static folder path for sorted images
SORTED_FOLDER = r"C:\Users\Admin\Desktop\rangmahal (2)\rangmahal\server_code\data\sorted_data"

@app.route('/images/<gender>/<article>/<filename>')
def get_image(gender, article, filename):
    image_path = os.path.join(SORTED_FOLDER, gender, article)
    if not os.path.exists(os.path.join(image_path, filename)):
        return jsonify({"error": "Image not found"}), 404
    return send_from_directory(image_path, filename)

# ✅ Get images by discount percentages
@app.route('/get_images', methods=['GET'])
def get_images_with_50():
    genders = request.args.get("genders", "")
    articles = request.args.get("articles", "")
    return jsonify(fetch_images_with_discount(genders, articles, 0.5))

@app.route('/get_images_20', methods=['GET'])
def get_images_with_20():
    genders = request.args.get("genders", "")
    articles = request.args.get("articles", "")
    return jsonify(fetch_images_with_discount(genders, articles, 0.2))

@app.route('/get_images_30', methods=['GET'])
def get_images_with_30():
    genders = request.args.get("genders", "")
    articles = request.args.get("articles", "")
    return jsonify(fetch_images_with_discount(genders, articles, 0.3))

@app.route('/get_images_40', methods=['GET'])
def get_images_with_40():
    genders = request.args.get("genders", "")
    articles = request.args.get("articles", "")
    return jsonify(fetch_images_with_discount(genders, articles, 0.4))

# ✅ Get images by colour match
@app.route('/get_images_by_colour', methods=['GET'])
def get_images_by_colour():
    genders = request.args.get("genders", "")
    articles = request.args.get("articles", "")
    return jsonify(fetch_images_with_matching_colour(genders, articles, 0.5))

# ✅ Get images by brand
@app.route('/get_by_brand', methods=['GET'])
def get_brand():
    genders = request.args.get("genders", "")
    articles = request.args.get("articles", "")
    brand = request.args.get("brand", "")
    return jsonify(fetch_images_by_brand(genders, articles, brand))

# ✅ Add order
@app.route('/add_order_path', methods=['POST'])
def add_order_route():
    try:
        return add_order()
    except Exception as e:
        print(f"Error: {str(e)}")
        return jsonify({"message": "Error while placing order", "error": str(e)}), 500
# ✅ Get current orders
@app.route('/get_orders', methods=['GET'])
def get_orders_route():
    try:
        return get_orders()
    except Exception as e:
        return jsonify({"message": "Error fetching orders", "error": str(e)}), 500

# ✅ Get archived orders
@app.route('/get_archived_orders', methods=['GET'])
def get_archived_orders_route():
    try:
        return get_archived_orders()
    except Exception as e:
        return jsonify({"message": "Error fetching archived orders", "error": str(e)}), 500

# ✅ Recommendation route
@app.route('/recommend', methods=['GET'])
def recommend_api():
    brand = request.args.get("brand")
    if not brand:
        return jsonify({"error": "Missing brand name"}), 400

    image_names = recommend_tshirt(brand)
    image_info = get_image_info(image_names)
    return jsonify({"recommended": image_info})

@app.route('/recommend_from_itemstring', methods=['GET'])
def recommend_from_itemstring():
    user_id = request.args.get("user_id")
    if not user_id:
        return jsonify({"error": "Missing user_id"}), 400

    parsed_items = parse_ordered_items(user_id)
    all_recommendations = []
    for article_norm, gender in parsed_items:
        recs = recommend_from_folder(article_norm, gender)
        all_recommendations.extend(recs)

    return jsonify({"recommended": all_recommendations})




@app.route('/recommend_no_brand', methods=['GET'])
def recommend_no_brand_api():
    image_names = recommend_tshirt_no_brand()
    image_info = get_image_info(image_names)
    return jsonify({"recommended": image_info})
















# ✅ Start the app
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
