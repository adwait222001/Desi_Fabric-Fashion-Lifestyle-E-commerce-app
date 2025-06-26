import 'package:flutter/material.dart';
import 'shared_cart.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final List<Map<String, dynamic>> relatedProducts;

  const DetailPage({
    super.key,
    required this.product,
    required this.relatedProducts,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPage = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productInfo = widget.product["product_info"];
    final String? productName = productInfo["productName"];
    final String? brand = productInfo["brand"];
    final dynamic price = productInfo["price"];
    final dynamic discountedPrice = productInfo["discountedPrice"];
    final String? gender = productInfo["gender"];

    final List<dynamic> styleImages = productInfo["styleImages"] ?? [];

    final List<String> imageUrls = [
      widget.product["image_url"],
      ...styleImages.map((img) => img["url"]).whereType<String>(),
    ];

    final filteredProducts = widget.relatedProducts
        .where((p) =>
    p["product_info"]["productName"] != productName &&
        p["product_info"]["gender"] == gender)
        .take(6)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(productName ?? "Product Detail")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔁 PageView with Gesture + Zoom Dialog
            SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: imageUrls.length,
                    onPageChanged: (index) => _currentPage.value = index,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.black,
                              insetPadding: EdgeInsets.zero,
                              child: Stack(
                                children: [
                                  InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 1,
                                    maxScale: 5,
                                    child: Center(
                                      child: Image.network(
                                        imageUrls[index],
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.broken_image,
                                            size: 150, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 30,
                                    right: 20,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white, size: 30),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image,
                                size: 150, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                  // Dots indicator
                  Positioned(
                    bottom: 10,
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentPage,
                      builder: (context, currentIndex, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(imageUrls.length, (index) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentIndex == index
                                    ? Colors.white
                                    : Colors.grey.shade400,
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(
              productName ?? "No name available",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            if (brand != null)
              Text("Brand: $brand", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            if (price != null && discountedPrice != null) ...[
              Text(
                "Price: ₹$price",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Discounted Price: ₹$discountedPrice",
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
            ] else if (discountedPrice != null) ...[
              Text(
                "Price: ₹$discountedPrice",
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            ] else if (price != null) ...[
              Text(
                "Price: ₹$price",
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
            ],
            const SizedBox(height: 25),

            // 🔁 Suggested Products
            if (filteredProducts.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "You may also like",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 290,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final item = filteredProducts[index];
                    final info = item["product_info"];

                    return GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              product: item,
                              relatedProducts: widget.relatedProducts,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                  child: Image.network(
                                    item["image_url"],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image,
                                        size: 80, color: Colors.grey),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      info["productName"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "₹${info["price"]}",
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  sharedCartManager.addToCart(item);
                                  sharedCartManager.showCartDialog(context, () {});
                                },
                                child: const Text("Buy Now",
                                    style: TextStyle(fontSize: 14)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            ElevatedButton(
              onPressed: () {
                sharedCartManager.addToCart(widget.product);
                sharedCartManager.showCartDialog(context, () {});
              },
              child: const Text("Buy Now", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
