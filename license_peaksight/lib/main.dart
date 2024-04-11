import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:license_peaksight/authentication/login_page.dart';
import 'package:license_peaksight/constants.dart';
import 'package:license_peaksight/firebase_options.dart';
import 'package:http/http.dart' as http;

Future<void> testInternetConnection() async {
  try {
    final result = await http.get(Uri.parse('https://google.com'));
    if (result.statusCode == 200) {
      print('Connected to the internet.');
    } else {
      print('Failed to connect to the internet.');
    }
  } catch (e) {
    print('Error checking internet connectivity: $e');
  }
}

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

  // Optionally test internet connectivity
  await testInternetConnection();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Peak Sight',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Constants.purpleDark,
        canvasColor: Constants.purpleLight
      ),
      home: LoginPage(), // Set LoginPage as the home widget
    );
  }
}
