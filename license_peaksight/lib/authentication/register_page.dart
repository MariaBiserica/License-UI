import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'authentication_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

enum AvatarSelectionOption { enterUrl, pickImage, choosePredefined }

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  String email = '';
  String password = '';
  String username = '';
  String? avatarUrl; // URL for the uploaded or selected avatar
  XFile? _image; // Selected image file
  AvatarSelectionOption? _avatarSelectionOption;

  // Predefined avatar images (assuming these are local assets)
  List<String> predefinedAvatars = [
    'assets/profile_avatars/avatar1.png',
    'assets/profile_avatars/avatar2.png',
  ];

  // URLs for predefined avatars if already uploaded to Firebase Storage
  List<String> predefinedAvatarUrls = [
    'URL_for_avatar1_in_Firebase_Storage',
    'URL_for_avatar2_in_Firebase_Storage',
  ];

  int selectedAvatarIndex = -1; // No avatar selected by default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) => setState(() => email = val),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                onChanged: (val) => setState(() => password = val),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Username'),
                validator: (val) => val!.isEmpty ? 'Enter a username' : null,
                onChanged: (val) => setState(() => username = val),
              ),
              // UI for selecting avatar option
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => _avatarSelectionOption = AvatarSelectionOption.enterUrl),
                    child: Text('Enter Image URL'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => _avatarSelectionOption = AvatarSelectionOption.pickImage),
                    child: Text('Pick Image from Gallery'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => _avatarSelectionOption = AvatarSelectionOption.choosePredefined),
                    child: Text('Choose Predefined'),
                  ),
                ],
              ),
              if (_avatarSelectionOption == AvatarSelectionOption.enterUrl)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Image URL'),
                  onChanged: (val) => avatarUrl = val,
                ),
              if (_avatarSelectionOption == AvatarSelectionOption.pickImage && _image != null)
                Image.file(File(_image!.path), width: 100, height: 100),
              if (_avatarSelectionOption == AvatarSelectionOption.choosePredefined)
                Wrap(
                  spacing: 10,
                  children: List<Widget>.generate(predefinedAvatars.length, (index) {
                    return OutlinedButton(
                      onPressed: () => _selectPredefinedAvatar(index),
                      child: Image.asset(predefinedAvatars[index], width: 50, height: 50),
                    );
                  }),
                ),
              ElevatedButton(
                onPressed: _registerUser,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
        selectedAvatarIndex = -1; // Reset the predefined avatar selection
      });
    }
  }

  void _selectPredefinedAvatar(int index) {
    setState(() {
      selectedAvatarIndex = index;
      _image = null; // Clear the image picked from the gallery
      avatarUrl = predefinedAvatarUrls[index]; // Use predefined avatar URL
    });
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) {
      // Provide feedback that form validation failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form validation failed'),
        ),
      );
      return;
    }
    bool exists = await _authService.usernameExists(username);
    if (exists) {
      // Show an error if the username exists
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Username already exists. Please choose another.'),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    // If a gallery image was selected, upload it to Firebase Storage and get the URL
    if (_avatarSelectionOption == AvatarSelectionOption.pickImage && _image != null) {
      String? imageUrl = await uploadImageToFirebase(_image!.path);
      if (imageUrl != null) {
        avatarUrl = imageUrl; // Set the uploaded image URL as the avatar URL
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error'),
            content: Text('Failed to upload image. Please try again.'),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
        return;
      }
    }

    // Proceed with registration using the obtained avatarUrl
    dynamic result = await _authService.signUpWithEmailAndPassword(
      email,
      password,
      username,
      avatarUrl, // Pass the final avatar URL here
    );

    if (result != null) {
      Navigator.pop(context); // Go back to the previous screen upon successful registration
    } else {
      // Handle registration error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Registration failed. Please try again.'),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
            ),
          ],
        ),
      );
    }
  }

  Future<String?> uploadImageToFirebase(String filePath, {String? predefinedPath}) async {
    File file = File(filePath);
    String fileName = predefinedPath ?? 'user_avatars/${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
    try {
      await firebase_storage.FirebaseStorage.instance
          .ref(fileName)
          .putFile(file);
      final String downloadUrl = await firebase_storage.FirebaseStorage.instance
          .ref(fileName)
          .getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print(e);
      return null;
    }
  }

}
