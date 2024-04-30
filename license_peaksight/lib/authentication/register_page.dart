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
  bool _isPasswordVisible = false; // State to toggle password visibility
  String username = '';
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
  ];

  // URLs for predefined avatars if already uploaded to Firebase Storage
  List<String> predefinedAvatarUrls = [
    'https://firebasestorage.googleapis.com/v0/b/peak-sight.appspot.com/o/predefined_avatars%2Favatar1.png?alt=media&token=032c8aa9-dd58-4eb2-942b-ba6a2b9471d4',
    'https://firebasestorage.googleapis.com/v0/b/peak-sight.appspot.com/o/predefined_avatars%2Favatar2.png?alt=media&token=f2314594-e2e2-4036-be30-64dff9ce0c27',
  ];

  CarouselController _carouselController = CarouselController();
  int _currentAvatarIndex = -1; // No avatar selected by default

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
                              'Register',
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
                        SizedBox(height: 20), // Add some spacing between the title and form fields
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'Enter your email address',
                            border: OutlineInputBorder(), // Adds a border to the input field
                            prefixIcon: Icon(Icons.email), // Adds an email icon before the text field
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please enter an email';
                            } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                          onChanged: (val) => setState(() => email = val),
                          keyboardType: TextInputType.emailAddress, // Optimizes the keyboard for email input
                          autocorrect: false, // Disables autocorrect
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter a password',
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
                        TextFormField(
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
                            decoration: InputDecoration(
                              labelText: 'Image URL',
                              hintText: 'Enter an image URL',
                              border: OutlineInputBorder(), // Adds a border to the input field
                              prefixIcon: Icon(Icons.image), // Adds an username icon before the text field
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
                          onPressed: _registerUser,
                          child: Text('Register'),
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(200, 36)), // Minimum size
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16)), // Padding inside the button
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Back to Login'),
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all(Size(200, 36)), // Minimum size
                            padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 16)), // Padding inside the button
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
    try {
      // Attempt to sign up the user with Firebase Auth
      User? user = await _authService.signUpWithEmailAndPassword(email, password);
      if (user != null) {
        // User is signed up, now create the Firestore user document
        await _authService.createUserDocument(user, username, avatarUrl);
        // Navigate to the next screen or show a success message
        Navigator.pop(context); // Go back to the previous screen upon successful registration
      } else {
        // Handle the case where the user couldn't be signed up
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Registration Error'),
            content: Text('Failed to create a new user.'),
            actions: <Widget>[
              TextButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Handle any errors that come from Firebase Auth
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text(e.toString()),
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
