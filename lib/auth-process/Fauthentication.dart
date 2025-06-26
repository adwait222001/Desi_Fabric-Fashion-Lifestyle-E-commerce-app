import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rangmahal/auth-process/profile.dart';
import 'package:rangmahal/shopee/homepage.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';
  bool showNewCard = false;
  String actionType = '';

  Future<void> signIn() async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = firebaseAuth.currentUser;
      final userId = user?.uid;

      if (userId == null) {
        throw Exception("User ID is null after sign-in");
      }

      // ✅ Check if image exists
      final imageRes = await http.get(
        Uri.parse('http://192.168.29.214:5000/test/$userId'),
      );


      // ✅ Check if username exists
      final nameRes = await http.post(
        Uri.parse('http://192.168.29.214:5000/cat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}),
      );

      final imageExists = imageRes.statusCode == 200;
      final nameExists = nameRes.statusCode == 200;

      if (imageExists && nameExists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Homepage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ImageUploadPage()),
        );
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Signed in")));
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'An error occurred';
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  Future<void> register() async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Registered successfully")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ImageUploadPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = e.message ?? 'An error has occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amberAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!showNewCard) ...[
              // Sign-In Card
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        showNewCard = true;
                        actionType = "Sign-In";
                      });
                    },
                    child: Text("Sign-In"),
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Register Card
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        showNewCard = true;
                        actionType = "Register";
                      });
                    },
                    child: Text("Register"),
                  ),
                ),
              ),
            ] else ...[
              // New card appearing after clicking Sign-In or Register
              Card(
                elevation: 5,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: actionType == "Sign-In" ? signIn : register,
                        child: Text(actionType),
                      ),
                      if (actionType == "Register") ...[
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              actionType = "Sign-In";
                            });
                          },
                          child: Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
