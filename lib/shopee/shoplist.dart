import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'detailpage.dart';
import 'shopping_cart.dart';
import 'shared_cart.dart'; // 👈 Add this import

class shoplist extends StatefulWidget {
  final List<String>? genders;
  final List<String>? articles;
  final String? brand;
  final String route;

  const shoplist({super.key, this.genders, this.articles, this.brand, required this.route});

  @override
  State<shoplist> createState() => _shoplistState();
}

class _shoplistState extends State<shoplist> {
  List<dynamic> images = [];
  bool isError = false;

  final CartManager cartManager = sharedCartManager; // 👈 Use shared instance

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    String baseIp = "http://192.168.29.214:5000";
    String baseUrl = "$baseIp${widget.route}";

    String genderQuery = widget.genders?.join(",") ?? "";
    String articleQuery = widget.articles?.join(",") ?? "";
    String brandQuery = widget.brand != null ? "&brand=${widget.brand}" : "";

    String url = "$baseUrl?genders=$genderQuery&articles=$articleQuery$brandQuery";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          images = (data["images"] as List?) ?? [];
          isError = images.isEmpty;
        });
      } else {
        setState(() => isError = true);
      }
    } catch (e) {
      setState(() => isError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TOP_PICKS_FOR_U"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              cartManager.showCartDialog(context, () => setState(() {}));
            },
          ),
        ],
      ),
      body: isError
          ? const Center(child: Text("Failed to load images", style: TextStyle(fontSize: 18, color: Colors.red)))
          : images.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.65,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            var imageItem = images[index];
            int quantity = cartManager.getQuantity(imageItem);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(
                      product: imageItem,
                      relatedProducts: images.take(6).cast<Map<String, dynamic>>().toList(),
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          imageItem["image_url"],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            imageItem["product_info"]["productName"],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // 💸 Pricing Section with discount logic
                          Builder(
                            builder: (_) {
                              final productInfo = imageItem["product_info"];
                              final price = productInfo["price"];
                              final discountedPrice = productInfo["discountedPrice"];

                              if (price != null && discountedPrice != null) {
                                return Column(
                                  children: [
                                    Text(
                                      "₹$price",
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                        decoration: TextDecoration.lineThrough,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹$discountedPrice",
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                );
                              } else if (discountedPrice != null) {
                                return Text(
                                  "₹$discountedPrice",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              } else {
                                return Text(
                                  "₹$price",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                            },
                          ),

                          const SizedBox(height: 8),
                          SizedBox(
                            height: 36,
                            width: 130,
                            child: quantity > 0
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      cartManager.decreaseQuantity(imageItem);
                                    });
                                  },
                                ),
                                Text(
                                  "$quantity",
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      cartManager.increaseQuantity(imageItem);
                                    });
                                  },
                                ),
                              ],
                            )
                                : ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  cartManager.addToCart(imageItem);
                                });
                              },
                              icon: const Icon(Icons.shopping_cart, size: 18),
                              label: const Text("Add to Cart", style: TextStyle(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
