import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:license_peaksight/constants.dart';
import '../predict_image_noise_level.dart';


class Person {
  String name;
  Color color;
  Person({required this.name, required this.color});
}

class PanelCenterPage extends StatefulWidget {
  final String imagePath;

  PanelCenterPage({required this.imagePath});

  @override
  _PanelCenterPageState createState() => _PanelCenterPageState();
}


class _PanelCenterPageState extends State<PanelCenterPage> {
  double? qualityScore;
  List<Person> _persons = [
    Person(name: "John Doe", color: Constants.orangeDark),
    Person(name: "Jane Doe", color: Constants.redDark),
    Person(name: "John Smith", color: Constants.redLight),
    Person(name: "Gilbert Smith", color: Constants.greenLight),
    Person(name: "Jane Smith", color: Constants.orangeLight),
  ];

  @override
  void initState() {
    super.initState();
    // Call the function to calculate the image quality score
    if (widget.imagePath.isNotEmpty) {
      calculateQualityScore();
    }
  }

  void calculateQualityScore() async {
    try {
      final score = await predictImageQuality(File(widget.imagePath));
      setState(() {
        qualityScore = score;
      });
    } catch (e) {
      print("Failed to load quality score: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: Constants.kPadding / 2,
                  top: Constants.kPadding / 2,
                  right: Constants.kPadding / 2),
              child: Card(
                color: Constants.purpleLight,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Container(
                  width: double.infinity,
                  child: ListTile(
                    title: Text(
                      "Products Available",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "82% Available",
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Chip(
                      label: Text(
                        "20,500",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: Constants.kPadding / 2,
                  bottom: Constants.kPadding,
                  top: Constants.kPadding,
                  left: Constants.kPadding / 2),
              child: Card(
                color: Constants.purpleLight,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: List.generate(
                    _persons.length,
                    (index) => ListTile(
                      leading: CircleAvatar(
                        radius: 15,
                        child: Text(
                          _persons[index].name.substring(0, 1),
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _persons[index].color,
                      ),
                      title: Text(
                        _persons[index].name,
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.message,
                          color: Colors.white,
                        ),
                      )
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Constants.kPadding),
              child: Card(
                color: Constants.purpleLight,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(Constants.kPadding),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          "Image Quality Score based on Noise Level",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          qualityScore != null ? "$qualityScore" : "No score calculated",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      // Button to trigger score calculation
                      ElevatedButton(
                        onPressed: calculateQualityScore,
                        child: Text('Calculate Score', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}