import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChangeAvatar extends StatefulWidget {
  const ChangeAvatar({super.key});

  @override
  State<ChangeAvatar> createState() => _ChangeAvatarState();
}

class _ChangeAvatarState extends State<ChangeAvatar> {
  Uint8List? _image;
  File? selectedImage;

  final List<String> avatars = [
    '/Users/angie/StudioProjects/flutter_app/profile_images/Dog.png',
    '/Users/angie/StudioProjects/flutter_app/profile_images/cat.png',
    '/Users/angie/StudioProjects/flutter_app/profile_images/bird.png',
    '/Users/angie/StudioProjects/flutter_app/profile_images/bunny.png',
  ];

  Future<void> updateAvatar(String selectedAvatar) async {
    String url = 'https://d10c-103-103-56-94.ngrok-free.app/profile';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access_token');

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'profile_picture': selectedAvatar}),
    );

    if (response.statusCode == 200) {
      // Avatar updated successfully
      print('Avatar updated successfully');
      await prefs.setString('profile_picture', selectedAvatar);
    } else {
      // Handle error
      print('Failed to update avatar: ${response.statusCode}');
    }
  }

  Future<void> pickImageFromGallery() async {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    File selectedImage = File(returnImage.path);
    File? localImage = await saveImageToLocalDirectory(selectedImage);
    if (localImage != null) {
      setState(() {
        selectedImage = localImage;
        setState(() {
          selectedImage = localImage;
          _image = localImage.readAsBytesSync();
        });
      _image = File(returnImage.path).readAsBytesSync();
    });
      await updateAvatar(localImage.path);
      await saveImagePath(localImage.path);
      Navigator.pop(context,true);
      }
  }

  Future<void> pickImageFromCamera() async {
    final returnImage = await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    File selectedImage = File(returnImage.path);
    File? localImage = await saveImageToLocalDirectory(selectedImage);
    if (localImage != null) {
      setState(() {
        selectedImage = localImage;
        selectedImage = localImage;
        _image = localImage.readAsBytesSync();
      });
      await updateAvatar(localImage.path);
      await saveImagePath(localImage.path);
      Navigator.pop(context,true);
    }
  }

  Future<File?> saveImageToLocalDirectory(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      String path = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      return await image.copy(path);
    } catch (e) {
      print('Error saving image to local directory: $e');
      return null;
    }
  }

  Future<void> saveImagePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_image_path', path);
  }

  Future<String?> getImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('saved_image_path');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: const Text('Choose your Avatar', style: TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold, color: Colors.white),),
          backgroundColor: Colors.red[800],
        ),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {pickImageFromGallery();},
                    child: const SizedBox(
                      child: Column(
                        children: [Icon(Icons.image, size: 100,), Text('Gallery')],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {pickImageFromCamera();},
                    child: const SizedBox(
                      child: Column(
                        children: [Icon(Icons.camera_alt, size: 100,), Text('Camera')],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: avatars.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await updateAvatar(avatars[index]);
                          Navigator.pop(context, true);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Image.file(File(avatars[index])),
                        ),
                      ),
                      if (index != avatars.length-1) const Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
    );
  }
}
