from flask import Flask, request, jsonify
import sqlite3
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Enable CORS for cross-origin requests

# Database setup
DATABASE = 'user_data.db'

def init_db():
    """Initialize the database if it does not exist."""
    try:
        with sqlite3.connect(DATABASE) as conn:
            cursor = conn.cursor()
            cursor.execute('''CREATE TABLE IF NOT EXISTS users (
                                id TEXT PRIMARY KEY,  -- Use TEXT to store Firebase UID
                                name TEXT NOT NULL UNIQUE
                              )''')
            conn.commit()
    except sqlite3.Error as e:
        print(f"Database initialization error: {e}")

@app.route('/add_name', methods=['POST'])
def add_name():
    """Endpoint to add a name to the database."""
    data = request.get_json()
    user_id = data.get('user_id')  # Firebase UID from the frontend
    name = data.get('name')
    
    if not user_id or not name:
        return jsonify({"message": "User ID and Name are required"}), 400

    try:
        with sqlite3.connect(DATABASE) as conn:
            cursor = conn.cursor()
            # Check if the user already exists in the database
            cursor.execute("SELECT id FROM users WHERE id = ?", (user_id,))
            existing_user = cursor.fetchone()
            
            if existing_user:
                return jsonify({"message": "User already exists in the database!"}), 400
            
            # If not, insert the new user
            cursor.execute("INSERT INTO users (id, name) VALUES (?, ?)", (user_id, name))
            conn.commit()
        
        return jsonify({"message": "Name entered successfully!"}), 200
    
    except sqlite3.Error as e:
        return jsonify({"message": f"Database error: {e}"}), 500

@app.route('/get_names', methods=['GET'])
def get_names():
    """Endpoint to retrieve all names from the database."""
    try:
        with sqlite3.connect(DATABASE) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT id, name FROM users")
            users = cursor.fetchall()
        
        # Convert list of tuples to a list of dictionaries
        users_list = [{"id": user[0], "name": user[1]} for user in users]
        return jsonify({"users": users_list}), 200

    except sqlite3.Error as e:
        return jsonify({"message": f"Database error: {e}"}), 500
@app.route('/show', methods=['POST'])
def show_name(user_id):  # Accept user_id as an argument
    print(f"Received user_id: {user_id}")  # Log the received user_id

    if not user_id:
        return jsonify({"message": "User ID is required"}), 400

    try:
        with sqlite3.connect(DATABASE) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT name FROM users WHERE id = ?", (user_id,))
            result = cursor.fetchone()
        
        if result:
            return jsonify({"user_id": user_id, "name": result[0]}), 200
        else:
            return jsonify({"message": "User ID not found in the database"}), 404

    except sqlite3.Error as e:
        return jsonify({"message": f"Database error: {e}"}), 500



if __name__ == '__main__':
    init_db()  # Initialize the database when the app starts
    app.run(host='0.0.0.0', port=5000, debug=True)
