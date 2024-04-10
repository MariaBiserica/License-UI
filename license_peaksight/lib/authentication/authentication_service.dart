import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email, password, username, and avatar URL
  Future signUpWithEmailAndPassword(
      String email, String password, String username, [String? avatarUrl]) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // If the user is successfully created, then add the additional
      // information to Firestore
      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).set({
          'username': username,
          'email': email,
          'avatarUrl': avatarUrl ?? '', // Use an empty string if no URL is provided
        });
      }

      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }
  
  // Sign in with email & password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // Check if a username already exists
  Future<bool> usernameExists(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('Users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isNotEmpty;
  }
}
