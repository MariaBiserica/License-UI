import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:license_peaksight/authentication/animated_background.dart';
import 'package:license_peaksight/authentication/register_page.dart';
import 'package:license_peaksight/authentication/user_model.dart';
import 'package:license_peaksight/widget_tree.dart';
import 'authentication_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PulsingBackground(), // Animated background
          Center(
            child: Card(
              elevation: 5.0,
              margin: EdgeInsets.symmetric(horizontal: 400),// Increase the margin for smaller fields
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    children: <Widget>[
                      CircleAvatar(
                        radius: 100,
                        child: Image.asset("images/logo.png"),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(labelText: 'Password'),
                        validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        child: Text('Login'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            dynamic result =
                                await _authService.signInWithEmailAndPassword(
                              _emailController.text,
                              _passwordController.text,
                            );
                            if (result == null) {
                              setState(() =>
                                  error = 'Could not sign in with those credentials');
                            } else {
                              UserModel? userModel = await fetchUserData();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WidgetTree(
                                      userAvatarUrl: userModel?.avatarUrl),
                                ),
                              );
                            }
                          }
                        },
                      ),
                      SizedBox(height: 12.0),
                      Text(
                        error,
                        style: TextStyle(color: Colors.red, fontSize: 14.0),
                      ),
                      TextButton(
                        child: Text('Register'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegisterPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<UserModel?> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          return UserModel.fromFirestore(
              userDoc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    return null;
  }
}
