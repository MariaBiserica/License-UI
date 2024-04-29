import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:license_peaksight/constants.dart';
import '../quality_assessment/get_quality_scores.dart';


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
  double? noiseScore;
  double? contrastScore;
  double? brightnessScore;
  double? sharpnessScore;
  double? chromaticScore;

  List<Person> _persons = [
    Person(name: "John Doe", color: Constants.endGradient),
    Person(name: "Jane Doe", color: Constants.beginGradient),
    Person(name: "John Smith", color: Constants.redLight),
    Person(name: "Gilbert Smith", color: Constants.greenLight),
    Person(name: "Jane Smith", color: Constants.orangeLight),
  ];

  @override
  void initState() {
    super.initState();
    // Call the function to calculate the image quality scores
    if (widget.imagePath.isNotEmpty) {
      calculateQualityScores();
    }
  }

  void calculateQualityScores() async {
    try {
      final scores = await predictImageQuality(File(widget.imagePath));
      setState(() {
        noiseScore = scores.noiseScore;
        contrastScore = scores.contrastScore;
        brightnessScore = scores.brightnessScore;
        sharpnessScore = scores.sharpnessScore;
        chromaticScore = scores.chromaticScore;
      });
    } catch (e) {
      print("Failed to load quality scores: $e");
    }
  }

  // Additional helper method to provide personalized message based on noise score
  String getQualityLevelMessage(double? score) {
    if (score == null) return "No score calculated";
    if (score > 5) return "Outlier quality, something is wrong";
    if (score > 4 && score <= 5) return "Excellent quality";
    if (score > 3 && score <= 4) return "Good quality";
    if (score > 2 && score <= 3) return "Fair quality";
    if (score > 1.50 && score <= 2) return "Poor quality";
    return "Bad quality";
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
                          "Image Noise Score",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          noiseScore != null 
                          ? "${noiseScore} - ${getQualityLevelMessage(noiseScore)}" 
                          : "No score calculated",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          "Image Contrast Score",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          contrastScore != null 
                          ? "${contrastScore} - ${getQualityLevelMessage(contrastScore)}" 
                          : "No score calculated",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          "Image Brightness Score",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          brightnessScore != null 
                          ? "${brightnessScore} - ${getQualityLevelMessage(brightnessScore)}" 
                          : "No score calculated",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          "Image Sharpness Score",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          sharpnessScore != null 
                          ? "${sharpnessScore} - ${getQualityLevelMessage(sharpnessScore)}" 
                          : "No score calculated",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ListTile(
                        title: Text(
                          "Image Chromatic Score",
                          style: TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          chromaticScore != null 
                          ? "${chromaticScore} - ${getQualityLevelMessage(chromaticScore)}" 
                          : "No score calculated",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      // Button to trigger scores calculation
                      ElevatedButton(
                        onPressed: calculateQualityScores,
                        child: Text('Calculate Scores', style: TextStyle(color: Colors.white)),
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