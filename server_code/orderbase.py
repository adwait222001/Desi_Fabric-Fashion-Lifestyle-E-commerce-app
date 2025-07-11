from flask import Flask, request, jsonify
import sqlite3
import json
from datetime import datetime, timedelta

app = Flask(__name__)

ORDER_DB = 'order_data.db'
HISTORY_DB = 'orderhistory.db'


def init_order_db():
    try:
        with sqlite3.connect(ORDER_DB) as conn:
            cursor = conn.cursor()
            cursor.execute('''CREATE TABLE IF NOT EXISTS users (
                                id TEXT PRIMARY KEY,
                                name TEXT NOT NULL UNIQUE
                              )''')
            cursor.execute('''CREATE TABLE IF NOT EXISTS orders (
                                order_id INTEGER PRIMARY KEY AUTOINCREMENT,
                                user_id TEXT NOT NULL,
                                items TEXT NOT NULL,
                                total_price REAL NOT NULL,
                                payment_method TEXT NOT NULL,
                                order_date TEXT NOT NULL,
                                delivery_date TEXT,
                                FOREIGN KEY(user_id) REFERENCES users(id)
                              )''')
            cursor.execute("PRAGMA table_info(orders)")
            columns = [column[1] for column in cursor.fetchall()]
            if 'delivery_date' not in columns:
                cursor.execute("ALTER TABLE orders ADD COLUMN delivery_date TEXT")

        with sqlite3.connect(HISTORY_DB) as conn:
            cursor = conn.cursor()
            cursor.execute('''CREATE TABLE IF NOT EXISTS order_history (
                                order_id INTEGER PRIMARY KEY,
                                user_id TEXT NOT NULL,
                                items TEXT NOT NULL,
                                total_price REAL NOT NULL,
                                payment_method TEXT NOT NULL,
                                order_date TEXT NOT NULL,
                                delivery_date TEXT
                              )''')
    except sqlite3.Error as e:
        print(f"Database initialization error: {e}")


def archive_expired_orders():
    try:
        now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with sqlite3.connect(ORDER_DB) as order_conn, sqlite3.connect(HISTORY_DB) as history_conn:
            order_cursor = order_conn.cursor()
            history_cursor = history_conn.cursor()

            order_cursor.execute("SELECT * FROM orders WHERE delivery_date < ?", (now,))
            expired_orders = order_cursor.fetchall()

            for row in expired_orders:
                history_cursor.execute('''
                    INSERT INTO order_history (order_id, user_id, items, total_price, payment_method, order_date, delivery_date)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                ''', (row[0], row[1], row[2], row[3], row[4], row[5], row[6]))

                order_cursor.execute("DELETE FROM orders WHERE order_id = ?", (row[0],))

            order_conn.commit()
            history_conn.commit()

        if expired_orders:
            print(f"[{datetime.now()}] Archived {len(expired_orders)} expired orders.")
    except sqlite3.Error as e:
        print(f"[ERROR] Failed to archive orders: {e}")


@app.route('/add_order_path', methods=['POST'])
def add_order():
    data = request.get_json()
    user_id = data.get('user_id')
    items = data.get('items')
    total_price = data.get('total_price')
    payment_method = data.get('payment_method')

    if not user_id or not items or total_price is None or not payment_method:
        return jsonify({"message": "Missing required fields"}), 400

    try:
        # 🔄 Extract and store only specific fields from each item (ignore price)
        processed_items = []
        for item in items:
            processed_item = {
                'productName': item.get('productName'),
                'brand': item.get('brand'),
                'quantity': item.get('quantity'),
                'colour': item.get('colour'),
                'productType': item.get('productType'),
                'image_url': item.get('image_url')
            }
            processed_items.append(processed_item)

        items_json = json.dumps(processed_items)
        order_date = datetime.now()
        delivery_date = order_date + timedelta(days=4)

        with sqlite3.connect(ORDER_DB) as conn:
            cursor = conn.cursor()
            cursor.execute('''INSERT INTO orders 
                              (user_id, items, total_price, payment_method, order_date, delivery_date) 
                              VALUES (?, ?, ?, ?, ?, ?)''',
                           (user_id, items_json, total_price, payment_method,
                            order_date.strftime("%Y-%m-%d %H:%M:%S"),
                            delivery_date.strftime("%Y-%m-%d %H:%M:%S")))
            conn.commit()

        return jsonify({"message": "Order placed successfully!"}), 200

    except sqlite3.Error as e:
        return jsonify({"message": f"Database error: {e}"}), 500


@app.route('/get_orders', methods=['GET'])
def get_orders():
    user_id = request.args.get('user_id')

    if not user_id:
        return jsonify({"message": "Missing user_id parameter"}), 400

    try:
        with sqlite3.connect(ORDER_DB) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM orders WHERE user_id = ?", (user_id,))
            orders = cursor.fetchall()

        orders_list = [dict(
            order_id=row[0],
            user_id=row[1],
            items=json.loads(row[2]),
            total_price=row[3],
            payment_method=row[4],
            order_date=row[5],
            delivery_date=row[6]
        ) for row in orders]

        return jsonify({"orders": orders_list}), 200
    except sqlite3.Error as e:
        return jsonify({"message": f"Database error: {e}"}), 500


@app.route('/get_archived_orders', methods=['GET'])
def get_archived_orders():
    user_id = request.args.get('user_id')

    if not user_id:
        return jsonify({"message": "Missing user_id parameter"}), 400

    try:
        with sqlite3.connect(HISTORY_DB) as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM order_history WHERE user_id = ?", (user_id,))
            rows = cursor.fetchall()

        order_list = [dict(
            order_id=row[0],
            user_id=row[1],
            items=json.loads(row[2]),
            total_price=row[3],
            payment_method=row[4],
            order_date=row[5],
            delivery_date=row[6]
        ) for row in rows]

        return jsonify({"archived_orders": order_list}), 200

    except sqlite3.Error as e:
        return jsonify({"message": f"Database error: {e}"}), 500


if __name__ == '__main__':
    init_order_db()
    app.run(debug=True, host='0.0.0.0', port=5000)
