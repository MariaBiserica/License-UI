import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:license_peaksight/authentication/animated_background/animated_background.dart';
import 'package:license_peaksight/authentication/faded_irregular_header_painter.dart';
import 'package:license_peaksight/authentication/authentication_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_auth/firebase_auth.dart';

class EditPage extends StatefulWidget {
  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Assume these fields are fetched from the user profile
  String email = '';
  String password = '';
  bool _isPasswordVisible = false;
  String username = '';
  String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PulsingBackground(),
          Center(
            child: Card(
              elevation: 5.0,
              margin: EdgeInsets.symmetric(horizontal: 300),
              child: Padding(
                padding: EdgeInsets.all(30),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Header with custom paint
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
                                color: Colors.white,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Fields pre-populated with user data
                        TextFormField(
                          initialValue: email,
                          decoration: InputDecoration(labelText: 'Email'),
                          validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                          onChanged: (val) => setState(() => email = val),
                        ),
                        TextFormField(
                          initialValue: username,
                          decoration: InputDecoration(labelText: 'Username'),
                          validator: (val) => val!.isEmpty ? 'Enter a username' : null,
                          onChanged: (val) => setState(() => username = val),
                        ),
                        SizedBox(height: 20),
                        // Buttons and other interactions
                        ElevatedButton(
                          onPressed: _updateProfile,
                          child: Text('Update Profile'),
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

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      // Update user profile in your database
      try {
        // Assume AuthService has an updateProfile method
        await _authService.updateUserProfile(email, username, avatarUrl);
        Navigator.pop(context); // Optionally navigate away after update
      } catch (e) {
        // Handle errors e.g., display an error dialog
        print('Error updating profile: $e');
      }
    }
  }
}
