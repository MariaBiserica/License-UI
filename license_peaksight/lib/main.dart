import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:license_peaksight/constants.dart';
import 'package:license_peaksight/firebase_options.dart';
import 'package:license_peaksight/widget_tree.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: WidgetTree(),
    );
  }
}
