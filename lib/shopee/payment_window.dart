import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'shopping_cart.dart'; // CartManager
import 'homepage.dart'; // Homepage

class PaymentWindow extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalPrice;
  final CartManager cartManager;

  const PaymentWindow({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.cartManager,
  });

  @override
  State<PaymentWindow> createState() => _PaymentWindowState();
}

class _PaymentWindowState extends State<PaymentWindow> {
  String _selectedPaymentMethod = 'Credit Card';

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose Payment Method"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: _selectedPaymentMethod,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                        DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                        DropdownMenuItem(value: 'COD', child: Text('Cash on Delivery')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPaymentMethod = value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _placeOrder();
                      },
                      child: const Text("Buy Now"),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    const String apiUrl = 'http://192.168.29.214:5000/add_order_path';

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorDialog("User not logged in.");
        return;
      }

      final String userId = user.uid;

      // ✅ Updated to include full item details
      List<Map<String, dynamic>> simplifiedItems = widget.cartItems.map((item) {
        final info = item['product_info'];
        return {
          'productName': info['productName'],
          'quantity': item['quantity'],
          'brand': info['brand'],
          'colour': info['colour'],
          'productType': info['productType'],
          'price': info['price'],
          'image_url': item['image_url'],
        };
      }).toList();

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'items': simplifiedItems,
          'total_price': widget.totalPrice,
          'payment_method': _selectedPaymentMethod,
        }),
      );

      if (response.statusCode == 200) {
        widget.cartManager.cart.clear();
        _showOrderSuccessDialog();
      } else {
        print('Failed to place order: ${response.body}');
        _showErrorDialog("Order failed. Please try again.");
      }
    } catch (e) {
      print('Error placing order: $e');
      _showErrorDialog("Something went wrong!");
    }
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Order Placed!"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://cdn-icons-png.flaticon.com/512/845/845646.png',
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Your order of ₹${widget.totalPrice.toStringAsFixed(2)} using $_selectedPaymentMethod has been placed.",
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Homepage()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _increaseQuantity(Map<String, dynamic> item) {
    setState(() {
      widget.cartManager.increaseQuantity(item);
    });
  }

  void _decreaseQuantity(Map<String, dynamic> item) {
    setState(() {
      widget.cartManager.decreaseQuantity(item);
    });
  }

  double _calculateTotalPrice() {
    return widget.cartManager.getTotalPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout Page")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                final quantity = item['quantity'];
                final price = item['product_info']['price'];

                return ListTile(
                  leading: Image.network(
                    item['image_url'],
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
                  ),
                  title: Text(item['product_info']['productName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Qty: $quantity"),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () => _decreaseQuantity(item),
                          ),
                          Text(quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _increaseQuantity(item),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Text("₹${price * quantity}"),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Total: ₹${_calculateTotalPrice().toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _showPaymentDialog,
                  child: const Text("Buy Now"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
