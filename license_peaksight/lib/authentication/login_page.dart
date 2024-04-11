import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onChanged: (val) {
                  setState(() => email = val);
                },
              ),
              SizedBox(height: 20.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Password too short' : null,
                onChanged: (val) {
                  setState(() => password = val);
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                child: Text('Login'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result = await _authService.signInWithEmailAndPassword(email, password);
                    if (result == null) {
                      setState(() => error = 'Could not sign in with those credentials');
                    } else {
                      // If login is successful, navigate to the WidgetTree page
                      UserModel? userModel = await fetchUserData();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WidgetTree(userAvatarUrl: userModel?.avatarUrl),
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
                  // Navigate to the register page
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<UserModel?> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      // Handle the error or return null
    }
    return null;
  }
}
