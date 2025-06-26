import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'package:rangmahal/shopee/homepage.dart';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _response = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image for your profile picture")),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter the profile name by which you will be identified")),
      );
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick image: $e")),
      );
    }
  }

  void _showImageSourceSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadAndAddName() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first.")),
      );
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a name.")),
      );
      return;
    }

    try {
      setState(() {
        _isUploading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _response.text = "User not authenticated!";
          _isUploading = false;
        });
        return;
      }

      String userId = user.uid;

      // Upload image
      var uri = Uri.parse('http://192.168.29.214:5000/image');
      var request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = userId;
      var file = await http.MultipartFile.fromPath('file', _image!.path);
      request.files.add(file);

      var imageResponse = await request.send();
      if (imageResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully!")),
        );
      } else {
        setState(() {
          _response.text = "Failed to upload image. Status: ${imageResponse.statusCode}";
        });
        return;
      }

      // Add name
      final nameResponse = await http.post(
        Uri.parse('http://192.168.29.214:5000/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'user_id': userId,
        }),
      );

      if (nameResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Name added successfully!")),
        );
        Navigator.push(context,MaterialPageRoute(builder: (context)=>Homepage()));
      } else {
        final responseData = json.decode(nameResponse.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Failed to add name.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _response.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Upload & Name Entry'),
      ),
      backgroundColor: Colors.blue.shade100,
      body:
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the column content
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () => _showImageSourceSelection(context),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8), // Adjust for rounded edges
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8), // Square with slight rounded corners
                  child: _image != null
                      ? Image.file(
                    _image!,
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  )
                      : Image.asset(
                    'assets/icons/icon.jpeg',
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Space between image and text field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Enter name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20), // Space between text field and button
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadAndAddName,
              child: const Text('Upload Image & Add Name'),
            ),
          ],
        ),
      ),
    );
  }
}
