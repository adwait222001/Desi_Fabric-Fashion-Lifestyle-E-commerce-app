import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // 🆕 Firebase Auth import

class Your_order extends StatefulWidget {
  const Your_order({super.key});

  @override
  State<Your_order> createState() => _Your_orderState();
}

class _Your_orderState extends State<Your_order> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  Future<void> fetchOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser; // 🆕 Get Firebase user
      if (user == null) {
        throw Exception('User not logged in');
      }
      print("Current User ID: ${user.uid}");
      final response = await http.get(
        Uri.parse('http://192.168.29.214:5000/get_orders?user_id=${user.uid}'), // 🆕 Pass UID
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['orders'] != null) {
          if (!mounted) return;
          setState(() {
            orders = List<Map<String, dynamic>>.from(data['orders']);
            isLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load orders');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchOrders(); // Fetch orders on init
  }

  void showOrderDetailsDialog(Map<String, dynamic> order) {
    String orderDate = order['order_date'].split(' ')[0];
    String deliveryDate = order['delivery_date'].split(' ')[0];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Order Details - Order ID: ${order['order_id']}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Date: $orderDate'),
                Text('Delivery Date: $deliveryDate'),
                Text('Total Price: ₹${order['total_price']}'),
                Text('Payment Method: ${order['payment_method']}'),
                Divider(),
                Text('Items:'),
                ...List<Widget>.from(order['items'].map((item) {
                  if (item != null && item['productName'] != null) {
                    return Text('Product: ${item['productName']} | Quantity: ${item['quantity']}');
                  } else {
                    return Text('Invalid item data');
                  }
                })),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? Center(child: Text('No orders found.'))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          String deliveryDate = order['delivery_date'].split(' ')[0];

          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Row(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Order ID: ${order['order_id']}'),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Price: ₹${order['total_price']}'),
                  Text('Delivery Date: $deliveryDate'),
                ],
              ),
              onTap: () {
                showOrderDetailsDialog(order);
              },
            ),
          );
        },
      ),
    );
  }
}
