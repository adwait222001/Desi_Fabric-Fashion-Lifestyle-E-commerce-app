from flask import Flask, jsonify, request, send_from_directory
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)

UPLOAD_FOLDER = 'uploads/'
if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

@app.route('/files', methods=['GET', 'POST'])
def handle_files():
    if request.method == 'POST':
        if 'file' not in request.files or 'user_id' not in request.form:
            return jsonify({'message': 'Missing file or user ID'}), 400

        file = request.files['file']
        user_id = request.form['user_id']

        if file.filename == '':
            return jsonify({'message': 'No selected file'}), 400

        _, extension = os.path.splitext(file.filename)
        filename = f"{user_id}{extension}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        return jsonify({'message': f'File uploaded successfully as {filename}'}), 200

    if request.method == 'GET':
        files = os.listdir(app.config['UPLOAD_FOLDER'])
        if not files:
            return jsonify({'message': 'No files found'}), 404
        return jsonify({'uploaded_files': files}), 200

@app.route('/image/<user_id>', methods=['GET'])
def fetch_image(user_id):
    try:
        filename = next((f for f in os.listdir(app.config['UPLOAD_FOLDER']) if f.startswith(user_id)), None)
        if filename:
            return send_from_directory(app.config['UPLOAD_FOLDER'], filename)
        else:
            return jsonify({'message': 'File not found'}), 404
    except Exception as e:
        return jsonify({'message': 'Error fetching file', 'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
