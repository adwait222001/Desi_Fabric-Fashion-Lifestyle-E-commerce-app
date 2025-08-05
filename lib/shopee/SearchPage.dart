import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'detailpage.dart';
import 'shopping_cart.dart';
import 'shared_cart.dart';

class AccordingToYourSearch extends StatefulWidget {
  final String query;

  const AccordingToYourSearch({super.key, required this.query});

  @override
  State<AccordingToYourSearch> createState() => _AccordingToYourSearchState();
}

class _AccordingToYourSearchState extends State<AccordingToYourSearch> {
  List<dynamic> products = [];
  bool isError = false;
  bool isLoading = true;

  final CartManager cartManager = sharedCartManager;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    String baseIp = "http://192.168.29.214:5000";
    String encodedQuery = Uri.encodeComponent(widget.query);
    String url = "$baseIp/match_products?query=$encodedQuery";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          products = (data["results"] as List?) ?? [];
          isError = products.isEmpty;
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        isLoading = false;
      });
    }
  }

  /// Convert API product to cart-compatible + DetailPage-compatible format
  Map<String, dynamic> adaptProduct(Map<String, dynamic> product) {
    String imageUrl = '';

    if (product["image_url"] != null &&
        product["image_url"].toString().trim().isNotEmpty) {
      imageUrl = product["image_url"];
    } else if (product["styleImages"] is List &&
        product["styleImages"].isNotEmpty) {
      imageUrl = product["styleImages"][0]["url"] ?? '';
    }

    return {
      "product_info": {
        "productName": product["productName"] ?? "",
        "brand": product["brand"] ?? "",
        "price": product["price"],
        "discountedPrice": product["discountedPrice"],
        "gender": product["gender"],
        "styleImages": product["styleImages"] ?? [],
      },
      "image_url": imageUrl,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Results for '${widget.query}'"),
        backgroundColor: Colors.purpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              cartManager.showCartDialog(context, () => setState(() {}));
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? const Center(
        child: Text(
          "No results found",
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(15.0),
        child: GridView.builder(
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.65,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index];
            var adapted = adaptProduct(product);

            int quantity = cartManager.getQuantity(adapted);

            List<dynamic> styleImages =
                product["styleImages"] ?? [];

            return GestureDetector(
              onTap: () {
                var adaptedProduct = adaptProduct(product);
                var adaptedRelatedProducts = products
                    .map((p) =>
                    adaptProduct(p as Map<String, dynamic>))
                    .cast<Map<String, dynamic>>()
                    .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(
                      product: adaptedProduct,
                      relatedProducts: adaptedRelatedProducts,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Product Image Carousel
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        child: styleImages.isNotEmpty
                            ? PageView.builder(
                          itemCount: styleImages.length,
                          itemBuilder: (context, imgIndex) {
                            return Image.network(
                              styleImages[imgIndex]["url"],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error,
                                  stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                                size: 80,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                            : const Icon(Icons.broken_image,
                            size: 80, color: Colors.grey),
                      ),
                    ),

                    // Product Info
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            product["productName"] ?? "",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹${product["price"] ?? "N/A"}",
                            style: const TextStyle(
                                color: Colors.green,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          // Add to Cart Button
                          SizedBox(
                            height: 36,
                            width: 130,
                            child: quantity > 0
                                ? Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove,
                                      size: 18),
                                  onPressed: () {
                                    setState(() {
                                      cartManager
                                          .decreaseQuantity(
                                          adapted);
                                    });
                                  },
                                ),
                                Text(
                                  "$quantity",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      size: 18),
                                  onPressed: () {
                                    setState(() {
                                      cartManager
                                          .increaseQuantity(
                                          adapted);
                                    });
                                  },
                                ),
                              ],
                            )
                                : ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  cartManager
                                      .addToCart(adapted);
                                });
                              },
                              icon: const Icon(
                                  Icons.shopping_cart,
                                  size: 18),
                              label: const Text(
                                  "Add to Cart",
                                  style:
                                  TextStyle(fontSize: 13)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6),
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
