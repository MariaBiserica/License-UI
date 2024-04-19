import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:license_peaksight/authentication/animated_background/animated_background.dart';
import 'package:license_peaksight/authentication/register_page.dart';
import 'package:license_peaksight/authentication/user_model.dart';
import 'package:license_peaksight/widget_tree.dart';
import 'authentication_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String error = '';
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _positionAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticInOut),
    )..addListener(() {
      setState(() {});
    });

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PulsingBackground(), // Animated background
          Center(
            child: Padding(
              padding: EdgeInsets.all(60),
              // Card widget for the login form
              child: Card( 
                elevation: 5.0,
                margin: EdgeInsets.symmetric(horizontal: 250), // Increased padding for the card
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Transform.translate(
                        offset: Offset(MediaQuery.of(context).size.width * _positionAnimation.value, 0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(10)), // Rounded corners for the left side
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("images/welcome5_5.png"), // Your background image
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    'Welcome Back!',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow( // Shadow for text outline effect
                                          blurRadius: 3.0,
                                          color: Colors.black,
                                          offset: Offset(2.0, 2.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    'Sign in to continue.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow( // Shadow for text outline effect
                                          blurRadius: 3.0,
                                          color: Colors.black,
                                          offset: Offset(1.5, 1.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            shrinkWrap: true,
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
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      // Toggle between icons based on the state
                                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                                    ),
                                    onPressed: () {
                                      // Toggle the state on icon press
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: !_isPasswordVisible, // Toggle visibility
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
                  ],
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
        if (userDoc.exists && userDoc.data() != null) {
          // Make sure to safely cast the data
          Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
          if (userData != null) {
            return UserModel.fromFirestore(userData);
          }
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
    return null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
