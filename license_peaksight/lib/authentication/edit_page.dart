import 'dart:io';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:license_peaksight/authentication/animated_background/animated_background.dart';
import 'package:license_peaksight/authentication/faded_irregular_header_painter.dart';
import 'authentication_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';

enum AvatarSelectionOption { enterUrl, pickImage, choosePredefined }

class EditPage extends StatefulWidget {
  final String email;
  final String username;
  final String? avatarUrl;

  EditPage({
    required this.email,
    required this.username,
    this.avatarUrl,
  });

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  late String email;
  late String password;
  bool _isPasswordVisible = false; // State to toggle password visibility
  late String username;
  String? avatarUrl; // URL for the uploaded or selected avatar
  XFile? _image; // Selected image file
  AvatarSelectionOption? _avatarSelectionOption;
  bool _showCarouselArrows = false; // Controls the visibility of carousel arrows
  int _hoverIndex = -1; // To keep track of which image is hovered in the carousel
  String? currentAvatarOption; // Holds the current selection from the dropdown

  // Dropdown menu options
  final List<DropdownMenuItem<String>> avatarOptions = [
    DropdownMenuItem(value: "enterUrl", child: Text("Enter Image URL")),
    DropdownMenuItem(value: "pickImage", child: Text("Pick Image from Gallery")),
    DropdownMenuItem(value: "choosePredefined", child: Text("Choose Predefined")),
  ];

  // Predefined avatar images (assuming these are local assets)
  List<String> predefinedAvatars = [
    'images/profile_avatars/avatar1.png',
    'images/profile_avatars/avatar2.png',
    'images/profile_avatars/avatar3.png',
    'images/profile_avatars/avatar4.png',
    'images/profile_avatars/avatar5.png',
  ];

  // URLs for predefined avatars if already uploaded to Firebase Storage
  List<String> predefinedAvatarUrls = [
    'https://firebasestorage.googleapis.com/v0/b/peak-sight.appspot.com/o/predefined_avatars%2Favatar1.png?alt=media&token=b4864658-00b9-4b67-a1cc-70a7fc2fe96f',
    'https://firebasestorage.googleapis.com/v0/b/peak-sight.appspot.com/o/predefined_avatars%2Favatar2.png?alt=media&token=c0a1ba86-4b47-4b0a-86de-8897e733fded',
    'https://firebasestorage.googleapis.com/v0/b/peak-sight.appspot.com/o/predefined_avatars%2Favatar3.png?alt=media&token=7277c976-7e5f-4206-8b69-3cd191c7239d',
    'https://firebasestorage.googleapis.com/v0/b/peak-sight.appspot.com/o/predefined_avatars%2Favatar4.png?alt=media&token=99ccd0ec-e1cc-4ae6-a9f3-814e85139a8a',
    'https://firebasestorage.googleapis.com/v0/b/peak-sight.appspot.com/o/predefined_avatars%2Favatar5.png?alt=media&token=354766bc-60f8-4dee-8028-085841d8dc25',
  ];

  CarouselController _carouselController = CarouselController();
  int _currentAvatarIndex = -1; // No avatar selected by default

  @override
  void initState() {
    super.initState();
    email = widget.email;
    username = widget.username;
    avatarUrl = widget.avatarUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PulsingBackground(), // Use the same animated background
          Center(
            child: Card(
              elevation: 5.0,
              margin: EdgeInsets.symmetric(horizontal: 300), // Increase the margin for smaller fields
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: Size(double.infinity, 130),
                              painter: FadedIrregularHeaderPainter(),
                            ),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Ensure contrast for readability
                                shadows: [
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 3.0,
                                    color: Color.fromARGB(150, 0, 0, 0),
                                  ),
                                ],
                                fontFamily: 'OpenSans',
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          initialValue: username,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'Enter a username',
                            border: OutlineInputBorder(), // Adds a border to the input field
                            prefixIcon: Icon(Icons.supervised_user_circle), // Adds an username icon before the text field
                          ),
                          validator: (val) => val!.isEmpty ? 'Enter a username' : null,
                          onChanged: (val) => setState(() => username = val),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your current password or a new one to change it',
                            border: OutlineInputBorder(), // Adds a border to the input field
                            prefixIcon: Icon(Icons.password), // Adds a password icon before the text field
                            suffixIcon: IconButton(
                              icon: Icon(
                                // Change the icon based on the state
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                              ),
                              onPressed: () {
                                // Update the state to toggle password visibility
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          obscureText: !_isPasswordVisible, // Use the state to toggle visibility
                          validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                          onChanged: (val) => setState(() => password = val),
                        ),
                        SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          value: currentAvatarOption,
                          hint: Text('Choose your avatar'),
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color.fromARGB(255, 200, 200, 210), width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              currentAvatarOption = newValue;
                              switch (newValue) {
                                case "enterUrl":
                                  _avatarSelectionOption = AvatarSelectionOption.enterUrl;
                                  _showCarouselArrows = false;
                                  break;
                                case "pickImage":
                                  _avatarSelectionOption = AvatarSelectionOption.pickImage;
                                  _showCarouselArrows = false;
                                  break;
                                case "choosePredefined":
                                  _avatarSelectionOption = AvatarSelectionOption.choosePredefined;
                                  _showCarouselArrows = true;
                                  break;
                              }
                            });
                          },
                          items: getDropdownItems(), // Use the method for styling dropdown items
                          dropdownColor: Colors.white,
                        ),
                        SizedBox(height: 20),
                        if (_avatarSelectionOption == AvatarSelectionOption.enterUrl)
                          TextFormField(
                            initialValue: avatarUrl,
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                              hintText: 'Enter an image URL',
                              border: OutlineInputBorder(), // Adds a border to the input field
                              prefixIcon: Icon(Icons.image), // Adds an image icon before the text field
                            ),
                            onChanged: (val) => avatarUrl = val,
                          ),
                        if (_avatarSelectionOption == AvatarSelectionOption.pickImage)
                          Column(
                            children: [
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _pickImageFromGallery, // Directly invoke the method when the button is pressed.
                                child: Text('Upload Image'),
                              ),
                              SizedBox(height: 20),
                              if (_image != null) // Check if an image has been picked and display it.
                                Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Image.file(File(_image!.path), width: 100, height: 100),
                                ),
                            ],
                          ),
                        if (_avatarSelectionOption == AvatarSelectionOption.choosePredefined)
                          Column(
                            children: [
                              CarouselSlider.builder(
                                itemCount: predefinedAvatars.length,
                                itemBuilder: (context, index, realIndex) {
                                  return MouseRegion(
                                    onEnter: (event) => _hovering(index),
                                    onExit: (event) => _notHovering(index),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      margin: EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0, 3),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Transform.scale(
                                        scale: _hoverIndex == index ? 1.05 : 1,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(15),
                                          child: Image.asset(predefinedAvatars[index], fit: BoxFit.cover),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                carouselController: _carouselController,
                                options: CarouselOptions(
                                  autoPlay: false,
                                  enlargeCenterPage: true,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _currentAvatarIndex = index;
                                      avatarUrl = predefinedAvatarUrls[index];
                                    });
                                  },
                                ),
                              ),
                              if (_showCarouselArrows)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(icon: Icon(Icons.arrow_back), onPressed: () => _carouselController.previousPage()),
                                    IconButton(icon: Icon(Icons.arrow_forward), onPressed: () => _carouselController.nextPage()),
                                  ],
                                ),
                            ],
                          ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _updateUser,
                          child: Text('Update Profile'),
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(200, 36)),
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16)),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel'),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 239, 219, 255)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to style dropdown items
  List<DropdownMenuItem<String>> getDropdownItems() {
    return [
      DropdownMenuItem(
        value: "enterUrl", 
        child: Container(
          child: Text("Enter Image URL"),
        )
      ),
      DropdownMenuItem(
        value: "pickImage", 
        child: Container(
          child: Text("Pick Image from Gallery"),
        )
      ),
      DropdownMenuItem(
        value: "choosePredefined", 
        child: Container(
          child: Text("Choose Predefined"),
        )
      ),
    ];
  }

  void _hovering(int index) {
    setState(() {
      _hoverIndex = index;
    });
  }

  void _notHovering(int index) {
    setState(() {
      if (_hoverIndex == index) {
        _hoverIndex = -1;
      }
    });
  }

  void _pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
        _currentAvatarIndex = -1; // Reset the predefined avatar selection
      });
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please correct the errors in the form.')),
      );
      return;
    }

    // If a gallery image was selected, upload it to Firebase Storage and get the URL
    if (_avatarSelectionOption == AvatarSelectionOption.pickImage && _image != null) {
      String? imageUrl = await uploadImageToFirebase(_image!.path);
      if (imageUrl != null) {
        avatarUrl = imageUrl;
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

    // Call the AuthService to update the user's profile
    try {
      await _authService.updateUserProfile(
        email: email, 
        username: username, 
        avatarUrl: avatarUrl,
        password: password.isNotEmpty ? password : null,
      );
      Navigator.pop(context); // Go back or show success message
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Profile Update Error'),
          content: Text('Failed to update profile. Error: $e'),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () => Navigator.of(context).pop(),
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
      print('Uploading file: $fileName');
      firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
          .ref(fileName)
          .putFile(file);

      // Get the snapshot when the upload is complete
      firebase_storage.TaskSnapshot snapshot = await task.whenComplete(() => {});
      
      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('File uploaded, download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Failed to upload image: $e');
      return null;
    }
  }

}
