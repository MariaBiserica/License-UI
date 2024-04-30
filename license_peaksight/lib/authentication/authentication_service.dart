import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email & password
  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } catch (error) {
      print(error.toString());
      throw error;  // Throw the error to be handled in the UI layer
    }
  }

  // Create a new user document in Firestore
  Future<void> createUserDocument(User user, String username, [String? avatarUrl]) async {
    await _firestore.collection('users').doc(user.uid).set({
      'username': username,
      'email': user.email,
      'avatarUrl': avatarUrl ?? '', // Use an empty string if no URL is provided
    });
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
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return result.docs.isNotEmpty;
  }

  // Method to get current user's ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Update user profile details
  Future<void> updateUserProfile({
    required String email, 
    required String username, 
    String? avatarUrl, 
    String? password
  }) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Update email if it has changed
      if (user.email != email) {
        await user.updateEmail(email);
      }

      // Update password if a new one is provided
      if (password != null && password.isNotEmpty) {
        await user.updatePassword(password);
      }

      // Update the display name and photo URL
      await user.updateProfile(displayName: username, photoURL: avatarUrl);

      // Update Firestore document
      await _firestore.collection('users').doc(user.uid).update({
        'username': username,
        'email': email,
        'avatarUrl': avatarUrl,
      });

      // You might want to re-authenticate the user here if you're updating sensitive information
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Optionally show a confirmation message
    } catch (e) {
      print('Error sending password reset email: $e');
      // Optionally handle errors, e.g., show an error message
    }
  }

}
