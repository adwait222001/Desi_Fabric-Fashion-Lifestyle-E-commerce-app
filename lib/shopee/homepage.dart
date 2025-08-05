import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rangmahal/shopee/orderhistory.dart';
import 'package:rangmahal/shopee/shoplist.dart';
import 'package:rangmahal/shopee/your_order.dart';

import '../main.dart';
import 'SearchPage.dart';
import 'bshoplist.dart';
import 'detailpage.dart';
import 'shopping_cart.dart';
import 'shared_cart.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final CartManager cartManager = CartManager();
  bool recommendation = false;
  bool _showSearch = false;
  TextEditingController _searchController = TextEditingController();


  @override


  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purpleAccent,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          title: _showSearch
              ? TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Search products...",
              border: InputBorder.none,
            ),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AccordingToYourSearch(query: value.trim()),
                  ),
                ).then((_) {
                  // 🔹 Reset search state when returning to homepage
                  setState(() {
                    _showSearch = false;
                    _searchController.clear();
                  });
                });
              }
            },
          )
              : const Text(""),
          actions: [
            IconButton(
              icon: Icon(_showSearch ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  if (_showSearch) {
                    // Closing search
                    _showSearch = false;
                    _searchController.clear();
                  } else {
                    // Opening search
                    _showSearch = true;
                  }
                });
              },
            ),
            IconButton(
              onPressed: () {
                sharedCartManager.showCartDialog(context, () {
                  setState(() {});
                });
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          ],
        ),

        drawer: const Sidebar(),
      body:
    Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 50, // strip width
            child: Column(
              children: [
                Expanded(child: Container(color: Colors.orange)),
                Expanded(child: Container(color: Colors.white)),
                Expanded(child: Container(color: Colors.green)),
              ],
            ),
          ),
        ),

        // Right strip
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            width: 50, // strip width
            child: Column(
              children: [
                Expanded(child: Container(color: Colors.orange)),
                Expanded(child: Container(color: Colors.white)),
                Expanded(child: Container(color: Colors.green)),
              ],
            ),
          ),
        ),
        SingleChildScrollView(        scrollDirection: Axis.vertical,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // PageView to Show One Card at a Time
            SizedBox(
              height: 300,
              width: 400,
              child: PageView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => shoplist(
                            genders: ["Men", "Women","Boys","Girls"],  // ✅ Pass multiple genders
                            articles: ["Tshirts","Jeans","Waistcoat","Stoles","Kurtis","Nehru jackets","Kurtas","Lehenga choli"], // ✅ Pass multiple articles
                            route: '/get_images',
                          ),
                        ),
                      );

                    },
                    child: Card(
                      color: Colors.yellowAccent,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Diwali-BlockBuster-\n",
                                        style: TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 40,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "50% Sale",
                                        style: TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomPaint(
                                      size: const Size(30, 140),
                                      painter: CurlyBracketsPainter(isLeft: true),
                                    ),
                                    Image.asset(
                                      "assets/cards_icons/diya.jpg",
                                      height: 140,
                                      width: 260,
                                      fit: BoxFit.cover,
                                    ),
                                    CustomPaint(
                                      size: const Size(30, 140),
                                      painter: CurlyBracketsPainter(isLeft: false),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => shoplist(
                            genders: ["Men"],  // ✅ Pass multiple genders
                            articles: ["Kurtis","Nehru jackets","Kurtas","Stoles"], // ✅ Pass multiple articles
                            route: '/get_images',
                          ),
                        ),
                      );
                    },
                    //work to be done in this card
                    child: Card(
                      color: Colors.purpleAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/cards_icons/mens1.jpg",
                                  height: 190,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: 20), // Space between images
                                Image.asset(
                                  "assets/cards_icons/mens2.jpg",
                                  height: 190,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                            SizedBox(height: 10), // Space between images and text
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "त्योहार की खुशी-\n",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "पारंपरिक परिधान के साथ!",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Normal Scrolling Row (Swapped Card Positions)
            SizedBox(
              height: 300,
              width: 400,
              child: PageView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: () {Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => shoplist(
                          genders: ["Men", "Women","Boys","Girls"],  // ✅ Pass multiple genders
                          articles: ["Kurtis","Nehru jackets","Kurtas","Lehenga choli"], // ✅ Pass multiple articles
                          route: '/get_images',
                        ),
                      ),
                    );
                    },
                    child: Card(
                      color: Colors.blue,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Center(
                              child: Image.asset(
                                "assets/cards_icons/family-diwali.jpg",
                                height: 250,
                                width: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "त्योहार की खुशी-\n",
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: "पारंपरिक परिधान के साथ!",
                                    style: TextStyle(
                                      color: Colors.deepOrange,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => shoplist(
                            genders: ["Women"],  // ✅ Pass multiple genders
                            articles: ["Sarees","Lehenga choli","Kurtis","Churidar","Dupatta","Kurta sets"], // ✅ Pass multiple articles
                            route: '/get_images',
                          ),
                        ),
                      );
                    },
                    //work to be done in this card
                    child: Card(
                      color: Colors.redAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/cards_icons/women1.jpg",
                                  height: 190,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(width: 20), // Space between images
                                Image.asset(
                                  "assets/cards_icons/women2.jpg",
                                  height: 190,
                                  width: 120,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                            SizedBox(height: 10), // Space between images and text
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "त्योहार की खुशी-\n",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "पारंपरिक परिधान के साथ!",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => shoplist(
                      genders: ["Boys","Girls"],  // ✅ Pass multiple genders
                      articles: ["Tshirts","Jeans","Waistcoat","Flip flops","Trousers"],
                      route: '/get_images_40',// ✅ Pass multiple articles
                    ),
                  ),
                );
              },
              child: Card(
                color: Colors.green,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      children: [
                        Center(
                          child: Image.asset(
                            "assets/cards_icons/childerens.jpg",
                            height: 250,
                            width: 240,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 1),
                        Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  text: "Top-Brands\n",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                                const SizedBox(height: 10), // Space added here
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: "Min.40%off",
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontSize: 20,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),],
                            )
                        ),
                      ]),
                ),
              ),
            ),
            const SizedBox(height: 30),
            if(recommendation)
              Row(children: [

              ],),

            //const SizedBox(height:30)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => shoplist(
                      genders: ["Men","Boys"],  // ✅ Pass multiple genders
                      articles: ["Tights","Tshirts","Sweatshirts","Caps","Jackets"], route: '/get_images_20', // ✅ Pass multiple articles
                    ),
                  ),
                );

              },
              child: Card(
                color: Colors.grey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/cards_icons/bhuvanbam.jpg",
                          height: 250,
                          width: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 1),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                text: "देख भाई,अपनी एंट्री\n",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10), // Space added here
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: "तो,स्टैग एंट्री होती है",
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 25,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height:20),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: "Top-Brands",
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontSize: 25,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: "20%-off",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 25,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => shoplist(
                      genders: ["Women","Girls"],  // ✅ Pass multiple genders
                      articles: ["Tights","Tshirts","Sweatshirts","Caps","Jackets","Skirts","Dress"], route: '/get_images_30', // ✅ Pass multiple articles
                    ),
                  ),
                );

              },
              child: Card(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/cards_icons/bharkasingh.jpg",
                          height: 250,
                          width: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 1),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                text: "I am queen of my life,\n",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10), // Space added here
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: "without need for a king",
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: "Top Brands with great discount\n",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: "Feel like a Queen\n",
                                  style: TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 25,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],)
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const RecommendationsWidgetc(),
            const SizedBox(height: 30),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => shoplist(
                      genders: ["Women","Men"],  // ✅ Pass multiple genders
                      articles: ["Tshirts"], route: '/get_images_by_colour', // ✅ Pass multiple articles
                    ),
                  ),
                );
              },
              child: Card(
                color: Colors.greenAccent,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Center(
                        child: Image.asset(
                          "assets/cards_icons/fashion-men-and-women.jpg",
                          height: 250,
                          width: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 1),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                text: "Style for Him & Her,\n",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10), // Space added here
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                text: "Find Your Perfect Tee!",
                                style: TextStyle(
                                  color: Colors.blue[800],
                                  fontSize: 19,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            RecommendationsWidget(brand: 'Nike'),
            //const SizedBox(height: 10),
            const Recommendationswidget(),
            const SizedBox(height: 10),

            const Row(children: [Text("Brands",style: TextStyle(color: Colors.black,fontSize: 20,fontStyle: FontStyle.italic,),
            )
            ],
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Bshoplist(
                                      genders: ["Women","Men"],  // ✅ Pass multiple genders
                                      articles: ["Tshirts","Sports shoes","SweatShirts"],
                                      brand: 'Nike',
                                      route:'/get_by_brand',
                                    ),
                                  ),
                                );

                              },
                              borderRadius: BorderRadius.circular(110),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(110),
                                child: Image.asset(
                                  'assets/brands-logos/nike.png',
                                  width: 150,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text("NIKE", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        SizedBox(width: 50),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Bshoplist(
                                      genders: ["Women","Men"],  // ✅ Pass multiple genders
                                      articles: ["Tshirts","Sports shoes","SweatShirts"],
                                      brand: 'ADIDAS',
                                      route:'/get_by_brand',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(110),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(110),
                                child: Image.asset(
                                  'assets/brands-logos/adidas.png',
                                  width: 160,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text("ADIDAS", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        const SizedBox(width: 40),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Bshoplist(
                                      genders: ["Women","Men"],  // ✅ Pass multiple genders
                                      articles: ["Shirts","Blazers"],
                                      brand: 'Reid %26 Taylor',
                                      route:'/get_by_brand',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(110),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(110),
                                child: Image.asset(
                                  'assets/brands-logos/reid_taylor.jpg',
                                  width: 150,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text("REID-TAYLOR", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Bshoplist(
                                      genders: ["Women","Men"],  // ✅ Pass multiple genders
                                      articles: ["Jeans"],
                                      brand: 'Flying Machine',
                                      route:'/get_by_brand',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(110),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(110),
                                child: Image.asset(
                                  'assets/brands-logos/flyingmachine.png',
                                  width: 180,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text("FLYING-MACHINE", style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Bshoplist(
                                      genders: ["Women","Men"],  // ✅ Pass multiple genders
                                      articles: ["Jeans","Tshirts"],
                                      brand: 'Lee',
                                      route:'/get_by_brand',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(110),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(110),
                                child: Image.asset(
                                  'assets/brands-logos/lee.jpg',
                                  width: 180,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Text("LEE", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            RecommendationsWidget(brand: 'Nike'),
            const SizedBox(height: 10),
            Center(child:Text("CATEGORIES",style: TextStyle(color: Colors.black,fontSize: 20,fontStyle: FontStyle.italic,),),),
            const SizedBox(height: 10),
            //look for this part of code
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    //route-check here
                                    builder: (context) => shoplist(
                                      genders: ["Men","Women","Boys","Girls"],  // ✅ Pass multiple genders
                                      articles: ["Caps"], // ✅ Pass multiple articles
                                      route: '/get_images_30',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(110),
                              child: SizedBox(
                                width: 150,
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(110),
                                  child: Image.asset(
                                    'assets/icons/cap_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text("CAPS", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        SizedBox(width: 50),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => shoplist(
                                      genders: ["Men","Women","Boys","Girls"],  // ✅ Pass multiple genders
                                      articles: ["Jeans"], // ✅ Pass multiple articles
                                      route: '/get_images_30',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(110),
                              child: SizedBox(
                                width: 150,
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(110),
                                  child: Image.asset(
                                    'assets/icons/jeans_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text("JEANS", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        const SizedBox(width: 40),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => shoplist(
                                      genders: ["Women","Men"],  // ✅ Pass multiple genders
                                      articles: ["Tshirts"], // ✅ Pass multiple articles
                                      route: '/get_images_30',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(110),
                              child: SizedBox(
                                width: 150,
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(110),
                                  child: Image.asset(
                                    'assets/icons/tshirt_logo.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text("T-Shirts", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        const SizedBox(width: 40),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => shoplist(
                                      genders: ["Women","Men"],  // ✅ Pass multiple genders
                                      articles: ["Casual shoes","Sport sandals","Formal shoes"], // ✅ Pass multiple articles
                                      route: '/get_images_30',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(110),
                              child: SizedBox(
                                width: 150,
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(110),
                                  child: Image.asset(
                                    'assets/icons/shoes_logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text("SHOES", style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => shoplist(
                                      genders: ["Women","Girls"],  // ✅ Pass multiple genders
                                      articles: ["Sarees","Lehenga choli","Churidar"], // ✅ Pass multiple articles
                                      route: '/get_images_30',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(120),
                              child: SizedBox(
                                width: 150,
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(110),
                                  child: Image.asset(
                                    'assets/icons/saree.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text("ETENIC-WEAR", style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // New row with fixed-sized ClipRRect
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => shoplist(
                                      genders: ["Men","Women","Girls"],  // ✅ Pass multiple genders
                                      articles: ["Backpacks","Duffel bag","Laptop bag","Backpacks"], // ✅ Pass multiple articles
                                      route: '/get_images_30',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(110),
                              child: SizedBox(
                                width: 150,
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(110),
                                  child: Image.asset(
                                    'assets/icons/backpack.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text("BAGS", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        SizedBox(width: 40),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => shoplist(
                                      genders: ["Women","Men"],  // ✅ Pass multiple genders
                                      articles: ["Blazers","Trousers","Ties","Formal shoes"], // ✅ Pass multiple articles
                                      route: '/get_images_30',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(110),
                              child: SizedBox(
                                width: 150,
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(110),
                                  child: Image.asset(
                                    'assets/icons/formals.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text("FORMALS", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        const SizedBox(width: 40),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => shoplist(
                                      genders: ["Women","Men"],  // ✅ Pass multiple genders
                                      articles: ["Lounge pants","Lounge shorts","shorts","Tshirts"], // ✅ Pass multiple articles
                                      route: '/get_images_30',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(110),
                              child: SizedBox(
                                width: 150,
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(110),
                                  child: Image.asset(
                                    'assets/icons/tshirt_logo.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text("CASUAL-WEAR", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => shoplist(
                                      genders: ["Women","Men"],  // ✅ Pass multiple genders
                                      articles: ["Sunglasses"], // ✅ Pass multiple articles
                                      route: '/get_images_30',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(110),
                              child: SizedBox(
                                width: 150,
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(110),
                                  child: Image.asset(
                                    'assets/icons/glasses.png',
                                    width: 100,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text("GLASSES", style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => shoplist(
                                      genders: ["Women"],  // ✅ Pass multiple genders
                                      articles: ["Dresses","Kurtis","Salwar and dupatta","Kurtas","Lehenga choli","Skirts","Tops"],
                                      route: '/get_images_30',
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(120),
                              child: SizedBox(
                                width: 150,
                                height: 100,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(110),
                                  child: Image.asset(
                                    'assets/icons/dress.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text("Dress", style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    ),]

    )

    );
  }
}
//here the main body code work is done
// Custom Painter for Curly Brackets
class CurlyBracketsPainter extends CustomPainter {
  final bool isLeft;

  CurlyBracketsPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    Path bracketPath = Path();

    if (isLeft) {
      bracketPath.moveTo(size.width, 0);
      bracketPath.quadraticBezierTo(
          0, size.height * 0.2, size.width * 0.5, size.height * 0.35);
      bracketPath.quadraticBezierTo(
          0, size.height * 0.5, size.width * 0.5, size.height * 0.65);
      bracketPath.quadraticBezierTo(
          0, size.height * 0.8, size.width, size.height);
    } else {
      bracketPath.moveTo(0, 0);
      bracketPath.quadraticBezierTo(
          size.width, size.height * 0.2, size.width * 0.5, size.height * 0.35);
      bracketPath.quadraticBezierTo(
          size.width, size.height * 0.5, size.width * 0.5, size.height * 0.65);
      bracketPath.quadraticBezierTo(
          size.width, size.height * 0.8, 0, size.height);
    }

    canvas.drawPath(bracketPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}






class ProductInfo {
  final String productName;
  final String brand;
  final int price;
  final int discountedPrice;

  ProductInfo({
    required this.productName,
    required this.brand,
    required this.price,
    required this.discountedPrice,
  });

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      productName: json['productName'] ?? '',
      brand: json['brand'] ?? '',
      price: json['price'] ?? 0,
      discountedPrice: json['discountedPrice'] ?? 0,
    );
  }
}

class StyleImage {
  final String type;
  final String url;

  StyleImage({required this.type, required this.url});

  factory StyleImage.fromJson(Map<String, dynamic> json) {
    return StyleImage(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class RecommendationItem {
  final String imageUrl;
  final ProductInfo productInfo;
  final List<StyleImage> styleImages;
  final String gender; // ✅ Add this

  RecommendationItem({
    required this.imageUrl,
    required this.productInfo,
    required this.styleImages,
    required this.gender, // ✅ Add to constructor
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    var styleImagesJson = json['styleImages'] as List<dynamic>? ?? [];

    return RecommendationItem(
      imageUrl: json['image_url'],
      productInfo: ProductInfo.fromJson(json['product_info']),
      styleImages: styleImagesJson
          .map((e) => StyleImage.fromJson(e as Map<String, dynamic>))
          .toList(),
      gender: json['gender'] ?? '', // ✅ Add this line
    );
  }
}
class RecommendResponse {
  final List<RecommendationItem> recommended;

  RecommendResponse({required this.recommended});

  factory RecommendResponse.fromJson(Map<String, dynamic> json) {
    var list = json['recommended'] as List<dynamic>? ?? [];
    return RecommendResponse(
      recommended: list
          .map((item) => RecommendationItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
Future<RecommendResponse?> fetchRecommendations(String brand) async {
  final uri = Uri.parse('http://192.168.29.214:5000/recommend?brand=nike'); // ✅ Update with actual IP
  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return RecommendResponse.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
class RecommendationsWidget extends StatelessWidget {
  final String brand;

  const RecommendationsWidget({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RecommendResponse?>(
      future: fetchRecommendations(brand),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.recommended.isEmpty) {
          return const SizedBox.shrink(); // Blank if loading, error, or empty
        }

        final items = snapshot.data!.recommended;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Top Selling Tshirts",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Horizontal Scroll List
            SizedBox(
              height: 330, // Extra height for Buy button
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final info = item.productInfo;

                  // Convert to Map format expected by sharedCartManager
                  final Map<String, dynamic> productMap = {
                    "image_url": item.imageUrl,
                    "product_info": {
                      "productName": info.productName,
                      "brand": info.brand,
                      "price": info.price,
                      "discountedPrice": info.discountedPrice,

                    },
                  };

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            product: productMap,
                            relatedProducts: items
                                .map((e) => {
                              "image_url": e.imageUrl,
                              "product_info": {
                                "productName": e.productInfo.productName,
                                "brand": e.productInfo.brand,
                                "price": e.productInfo.price,
                                "discountedPrice": e.productInfo.discountedPrice,
                              }
                            })
                                .toList(),
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 180,
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                child: Image.network(
                                  item.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                info.productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                info.brand,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    '₹${info.discountedPrice}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (info.discountedPrice < info.price)
                                    Text(
                                      '₹${info.price}',
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: ElevatedButton(
                                onPressed: () {
                                  sharedCartManager.addToCart(productMap);
                                  sharedCartManager.showCartDialog(context, () {});
                                },
                                child: const Text("Buy Now", style: TextStyle(fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}





//part2
class Styleimage {
  final String type;
  final String url;

  Styleimage({required this.type, required this.url});

  factory Styleimage.fromJson(Map<String, dynamic> json) {
    return Styleimage(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }
}
class ProductBInfo {
  final String productName;
  final String brand;
  final double price;
  final double discountedPrice;

  ProductBInfo({
    required this.productName,
    required this.brand,
    required this.price,
    required this.discountedPrice,
  });

  factory ProductBInfo.fromJson(Map<String, dynamic> json) {
    return ProductBInfo(
      productName: json['productName'],
      brand: json['brand'],
      price: (json['price'] as num).toDouble(),
      discountedPrice: (json['discountedPrice'] as num).toDouble(),
    );
  }
}
class ItemA {
  final String gender;
  final String imageName;
  final String imageUrl;
  final ProductBInfo productInfo;
  final List<Styleimage> styleImages;

  ItemA({
    required this.gender,
    required this.imageName,
    required this.imageUrl,
    required this.productInfo,
    required this.styleImages,
  });

  factory ItemA.fromJson(Map<String, dynamic> json) {
    return ItemA(
      gender: json['gender'],
      imageName: json['image_name'],
      imageUrl: json['image_url'],
      productInfo: ProductBInfo.fromJson(json['product_info']),
      styleImages: (json['styleImages'] as List<dynamic>)
          .map((e) => Styleimage.fromJson(e))
          .toList(),
    );
  }
}
class RecommendResult {
  final List<ItemA> recommended;

  RecommendResult({required this.recommended});

  factory RecommendResult.fromJson(Map<String, dynamic> json) {
    var list = json['recommended'] as List<dynamic>? ?? [];
    return RecommendResult(
      recommended: list
          .map((item) => ItemA.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
Future<RecommendResult?> fetchResult() async {
  try{
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    print("Current User ID: ${user.uid}");
    final response = await http.get(Uri.parse('http://192.168.29.214:5000/recommend_from_itemstring?user_id=${user.uid}'),);
    if (response.statusCode == 200) {
      return RecommendResult.fromJson(json.decode(response.body));
    } else {
      return null;
    }

  }catch(e){
    return null;
  }
}
class Recommendationswidget extends StatelessWidget {
  const Recommendationswidget({super.key});

  Future<RecommendResult?> fetchResult() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User not logged in');
        return null;
      }

      final url =
          'http://192.168.29.214:5000/recommend_from_itemstring?user_id=${user.uid}';
      print("Calling API: $url");

      final response = await http.get(Uri.parse(url));

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return RecommendResult.fromJson(json.decode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print("Exception during fetch: $e");
      return null;
    }
  }
  @override
  Widget build(BuildContext context)

  {
    return FutureBuilder<RecommendResult?>(
      future: fetchResult(),
      builder: (context, snapshot)
      {
        print('State: ${snapshot.connectionState}');
        print('Error: ${snapshot.error}');
        print('Data: ${snapshot.data}');
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.recommended.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!.recommended;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Based on ordered previously",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 330,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final info = item.productInfo;

                  final Map<String, dynamic> productMap = {
                    "image_url": item.imageUrl,
                    "product_info": {
                      "productName": info.productName,
                      "brand": info.brand,
                      "price": info.price,
                      "discountedPrice": info.discountedPrice,
                    },
                  };

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            product: productMap,
                            relatedProducts: items
                                .map((e) => {
                              "image_url": e.imageUrl,
                              "product_info": {
                                "productName": e.productInfo.productName,
                                "brand": e.productInfo.brand,
                                "price": e.productInfo.price,
                                "discountedPrice": e.productInfo.discountedPrice,
                              }
                            })
                                .toList(),
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 180,
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                child: Image.network(
                                  item.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                info.productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                info.brand,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    '₹${info.discountedPrice}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (info.discountedPrice < info.price)
                                    Text(
                                      '₹${info.price}',
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: ElevatedButton(
                                onPressed: () {
                                  sharedCartManager.addToCart(productMap);
                                  sharedCartManager.showCartDialog(context, () {});
                                },
                                child: const Text("Buy Now", style: TextStyle(fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}




//part3
class ProductInfoc {
  final String productName;
  final int price;
  final int discountedPrice;

  ProductInfoc({
    required this.productName,
    required this.price,
    required this.discountedPrice,
  });

  factory ProductInfoc.fromJson(Map<String, dynamic> json) {
    return ProductInfoc(
      productName: json['productName'] ?? '',
      price: json['price'] ?? 0,
      discountedPrice: json['discountedPrice'] ?? 0,
    );
  }
}

class StyleImagec {
  final String type;
  final String url;

  StyleImagec({required this.type, required this.url});

  factory StyleImagec.fromJson(Map<String, dynamic> json) {
    return StyleImagec(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class RecommendationItemc {
  final String imageUrl;
  final ProductInfoc productInfo;
  final List<StyleImagec> styleImages;
  final String gender;

  RecommendationItemc({
    required this.imageUrl,
    required this.productInfo,
    required this.styleImages,
    required this.gender,
  });

  factory RecommendationItemc.fromJson(Map<String, dynamic> json) {
    var styleImagesJson = json['styleImages'] as List<dynamic>? ?? [];

    return RecommendationItemc(
      imageUrl: json['image_url'],
      productInfo: ProductInfoc.fromJson(json['product_info']),
      styleImages: styleImagesJson
          .map((e) => StyleImagec.fromJson(e as Map<String, dynamic>))
          .toList(),
      gender: json['gender'] ?? '',
    );
  }
}

class RecommendResponsec {
  final List<RecommendationItemc> recommended;

  RecommendResponsec({required this.recommended});

  factory RecommendResponsec.fromJson(Map<String, dynamic> json) {
    var list = json['recommended'] as List<dynamic>? ?? [];
    return RecommendResponsec(
      recommended: list
          .map((item) =>
          RecommendationItemc.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

Future<RecommendResponsec?> fetchRecommendationsc() async {
  final uri = Uri.parse(
      'http://192.168.29.214:5000/recommend_no_brand'); // ✅ Updated endpoint

  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return RecommendResponsec.fromJson(json.decode(response.body));
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

class RecommendationsWidgetc extends StatelessWidget {
  const RecommendationsWidgetc({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RecommendResponsec?>(
      future: fetchRecommendationsc(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.recommended.isEmpty) {
          return const SizedBox.shrink();
        }

        final items = snapshot.data!.recommended;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    "Ethenic Wear",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Horizontal Scroll List
            SizedBox(
              height: 330, // Extra height for Buy button
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final info = item.productInfo;

                  // Map format expected by sharedCartManager
                  final Map<String, dynamic> productMap = {
                    "image_url": item.imageUrl,
                    "product_info": {
                      "productName": info.productName,
                      "price": info.price,
                      "discountedPrice": info.discountedPrice,
                    },
                  };

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            product: productMap,
                            relatedProducts: items
                                .map((e) => {
                              "image_url": e.imageUrl,
                              "product_info": {
                                "productName":
                                e.productInfo.productName,
                                "price": e.productInfo.price,
                                "discountedPrice":
                                e.productInfo.discountedPrice,
                              }
                            })
                                .toList(),
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 180,
                      child: Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8)),
                                child: Image.network(
                                  item.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                info.productName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  Text(
                                    '₹${info.discountedPrice}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (info.discountedPrice < info.price)
                                    Text(
                                      '₹${info.price}',
                                      style: const TextStyle(
                                        decoration:
                                        TextDecoration.lineThrough,
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              child: ElevatedButton(
                                onPressed: () {
                                  sharedCartManager.addToCart(productMap);
                                  sharedCartManager.showCartDialog(
                                    context,
                                        () {},
                                  );
                                },
                                child: const Text(
                                  "Buy Now",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

















// Sidebar Drawer
class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? _userId;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // Initialize the user ID and fetch the profile image
  Future<void> _initializeUser() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        _userId = user.uid; // Store the Firebase user ID
      });
      await _fetchProfileImage(); // Fetch the profile image based on user ID
    } else {
      setState(() {
        _userId = null;
        _imageUrl = null;
      });
    }
  }

  // Fetch the image from your Flask server
  Future<void> _fetchProfileImage() async {
    if (_userId == null) return;

    final url = Uri.parse(
        'http://192.168.29.214:5000/test/$_userId'); // Adjust this endpoint based on your server logic
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _imageUrl = url.toString(); // Store the image URL for display
        });
      } else {
        // Handle cases where the server does not return the image
        setState(() {
          _imageUrl = null;
        });
      }
    } catch (error) {
      // Handle network or other errors
      setState(() {
        _imageUrl = null;
      });
    }
  }

  Future<String> _getUserName(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    String value;

    if (user == null) {
      value = "user not authenticated";
      return value;
    }

    String userId = user.uid; // Get Firebase Authentication UID

    try {
      final response = await http.post(
        Uri.parse('http://192.168.29.214:5000/cat'), // Replace with your server URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}), // Pass the Firebase UID directly
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        String userName = responseData['name'];
        value = userName;
        return value;
      } else {
        final responseData = json.decode(response.body);
        return responseData['message'] ?? 'failed to fetch the user name';
      }
    } catch (e) {
      return ('Error occurred: $e');
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Updated signout function to navigate to the SplashScreen
  Future<void> signout(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()),  // Navigate to SplashScreen after sign-out
            (route) => false,  // This removes all previous routes
      );
    } on FirebaseAuthException catch (e) {
      // Handle error
      print("Error during sign out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Displaying the user profile
          FutureBuilder<String>(
            future: _getUserName(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const UserAccountsDrawerHeader(
                  accountName: Text("Loading..."),
                  accountEmail: null,
                );
              } else if (snapshot.hasError) {
                return UserAccountsDrawerHeader(
                  accountName: const Text("Error"),
                  accountEmail: null,
                  currentAccountPicture: ClipOval(
                    child: Icon(Icons.person, size: 50),
                  ),
                );
              } else {
                return UserAccountsDrawerHeader(
                  accountName: Text(snapshot.data ?? "Anonymous User"),
                  accountEmail: null,
                  currentAccountPicture: ClipOval(
                    child: _imageUrl != null
                        ? Image.network(_imageUrl!)
                        : Icon(Icons.person, size: 100),
                  ),
                );
              }
            },
          ),

          // Your Orders button
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Your_order()),
              );
            },
            label: Text("Your Orders"),
            icon: Icon(Icons.shopping_cart),
          ),
          SizedBox(height: 20),
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => orderhistory()),
              );
            },
            label: Text("Your Previous Orders"),
            icon: Icon(Icons.shopping_bag_rounded),
          ),



          // Sign out option
          ListTile(
            leading: Icon(Icons.logout_outlined),
            title: Text("Sign out"),
            onTap: () => signout(context),  // Use the updated signout method
          ),
        ],
      ),
    );
  }
}


