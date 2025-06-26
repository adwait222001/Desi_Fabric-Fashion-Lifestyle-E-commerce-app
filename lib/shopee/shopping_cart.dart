import 'package:flutter/material.dart';
import 'payment_window.dart'; // <-- Make sure this path is correct

class CartManager {
  List<Map<String, dynamic>> cart = [];

  void addToCart(Map<String, dynamic> product) {
    var existingItem = cart.firstWhere(
          (item) => item['image_url'] == product['image_url'],
      orElse: () => {},
    );

    if (existingItem.isNotEmpty) {
      existingItem['quantity'] = (existingItem['quantity'] ?? 0) + 1;
    } else {
      cart.add({
        ...product,
        "quantity": 1,
      });
    }
  }

  void increaseQuantity(Map<String, dynamic> product) {
    final index = cart.indexWhere((item) => item['image_url'] == product['image_url']);
    if (index != -1) {
      cart[index]["quantity"] += 1;
    }
  }

  void decreaseQuantity(Map<String, dynamic> product) {
    final index = cart.indexWhere((item) => item['image_url'] == product['image_url']);
    if (index != -1) {
      if (cart[index]["quantity"] > 1) {
        cart[index]["quantity"] -= 1;
      } else {
        cart.removeAt(index);
      }
    }
  }

  int getQuantity(Map<String, dynamic> product) {
    final existing = cart.firstWhere(
          (item) => item['image_url'] == product['image_url'],
      orElse: () => {},
    );
    return existing.isNotEmpty ? (existing['quantity'] ?? 0) : 0;
  }

  double getTotalPrice() {
    return cart.fold<double>(
      0.0,
          (sum, item) {
        final productInfo = item['product_info'] ?? {};
        final price = (productInfo['discountedPrice'] ?? productInfo['price'] ?? 0.0) as num;
        return sum + price.toDouble() * (item['quantity'] as int);
      },
    );
  }

  void showCartDialog(BuildContext context, Function externalRefresh) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Your Cart"),
              content: cart.isEmpty
                  ? const Text("Your cart is empty.")
                  : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    final productInfo = item['product_info'] ?? {};
                    final productName = productInfo['productName'] ?? 'Unnamed';
                    final displayPrice = (productInfo['discountedPrice'] ?? productInfo['price'] ?? 0)
                        .toString();
                    final imageUrl = item['image_url'] ?? '';

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        leading: Image.network(
                          imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported),
                        ),
                        title: Text(productName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Price: ₹$displayPrice"),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    decreaseQuantity(item);
                                    setState(() {});
                                    externalRefresh();
                                  },
                                ),
                                Text(item['quantity'].toString()),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    increaseQuantity(item);
                                    setState(() {});
                                    externalRefresh();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                Text(
                  "Total: ₹${getTotalPrice().toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: cart.isEmpty
                      ? null // Disable button if cart is empty
                      : () {
                    Navigator.of(context).pop(); // Close dialog

                    // ✅ UPDATED: pass `this` (CartManager instance) to PaymentWindow
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentWindow(
                          cartItems: cart,
                          totalPrice: getTotalPrice(),
                          cartManager: this, // <-- This line is new
                        ),
                      ),
                    );

                    externalRefresh();
                  },
                  child: const Text("Check-out"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
