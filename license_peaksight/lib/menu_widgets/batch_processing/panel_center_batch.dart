import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:license_peaksight/constants.dart';
import '../../quality_assessment/get_quality_scores.dart';

class PanelCenterBatchProcessing extends StatefulWidget {
  final List<String> imagePaths;
  final String selectedMetric;

  PanelCenterBatchProcessing({required this.imagePaths, required this.selectedMetric});

  @override
  _PanelCenterBatchProcessingState createState() => _PanelCenterBatchProcessingState();
}

class _PanelCenterBatchProcessingState extends State<PanelCenterBatchProcessing> {
  Map<String, double?> scoreMap = {};
  double progress = 0.0;
  Map<String, String> metricTiming = {};

  @override
  void didUpdateWidget(covariant PanelCenterBatchProcessing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMetric != oldWidget.selectedMetric || widget.imagePaths != oldWidget.imagePaths) {
      // Reset progress and initiate a new calculation
      progress = 0.0;
      metricTiming.clear();
      calculateQualityScores();  // Recalculate scores if selected metric or images change
    }
  }

  void calculateQualityScores() async {
    if (widget.imagePaths.isNotEmpty && widget.selectedMetric.isNotEmpty) {
      for (String imagePath in widget.imagePaths) {
        final scores = await predictImageQuality(File(imagePath), {widget.selectedMetric});

        if (scores != null) {
          setState(() {
            // Assigning values directly based on whether they were requested
            if (widget.selectedMetric == 'Noise') {
              scoreMap[imagePath] = scores.noiseScore;
              metricTiming[imagePath] = "${scores.noiseTime}";
            }
            if (widget.selectedMetric == 'Contrast') {
              scoreMap[imagePath] = scores.contrastScore;
              metricTiming[imagePath] = "${scores.contrastTime}";
            }
            if (widget.selectedMetric == 'Brightness') {
              scoreMap[imagePath] = scores.brightnessScore;
              metricTiming[imagePath] = "${scores.brightnessTime}";
            }
            if (widget.selectedMetric == 'Sharpness') {
              scoreMap[imagePath] = scores.sharpnessScore;
              metricTiming[imagePath] = "${scores.sharpnessTime}";
            }
            if (widget.selectedMetric == 'Chromatic Quality') {
              scoreMap[imagePath] = scores.chromaticScore;
              metricTiming[imagePath] = "${scores.chromaticTime}";
            }
            if (widget.selectedMetric == 'BRISQUE') {
              scoreMap[imagePath] = scores.brisqueScore;
              metricTiming[imagePath] = "${scores.brisqueTime}";
            }
            if (widget.selectedMetric == 'NIQE') {
              scoreMap[imagePath] = scores.niqeScore;
              metricTiming[imagePath] = "${scores.niqeTime}";
            }
            if (widget.selectedMetric == 'ILNIQE') {
              scoreMap[imagePath] = scores.ilniqeScore;
              metricTiming[imagePath] = "${scores.ilniqeTime}";
            }
            if (widget.selectedMetric == 'VGG16') {
              scoreMap[imagePath] = scores.vgg16Score;
              metricTiming[imagePath] = "${scores.vgg16Time}";
            }
          });
        } else {
          // Show a dialog if the scores are null
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Warning"),
                content: Text("Caught an exception while fetching data for $imagePath. Please try again if necessary."),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();  // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  String getQualityLevelMessage(double? score) {
    if (score == null) return "No score calculated";
    if (score > 5) return "Outlier score, image might be corrupted";
    if (score > 4 && score <= 5) return "Excellent";
    if (score > 3 && score <= 4) return "Good";
    if (score > 2 && score <= 3) return "Fair";
    if (score > 1.50 && score <= 2) return "Poor";
    return "Bad";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top overview card
            buildOverviewCard(),
            // Dynamic list of metric scores
            buildMetricsList(),
          ],
        ),
      ),
    );
  }

  Widget buildOverviewCard() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Constants.kPadding / 2, vertical: Constants.kPadding / 2),
        child: Card(
            color: Constants.purpleLight,
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
            ),
            child: Container(
                padding: const EdgeInsets.all(Constants.kPadding),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text(
                            "Analysis Overview",
                            style: TextStyle(
                                fontFamily: 'MOXABestine',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                        ),
                        SizedBox(height: 8),  // Space between title and subtitle
                        Text(
                            "Image quality MOS scale scores",
                            style: TextStyle(color: Color.fromARGB(156, 158, 158, 158)),
                        ),
                        SizedBox(height: 8), // Additional space before the table
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.black54, // Dark background for the table
                                borderRadius: BorderRadius.circular(10)
                            ),
                            child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                    children: [
                                        buildTableRow("Rating", "Quality Level", true),
                                        buildTableRow("5", "Excellent", false),
                                        buildTableRow("4", "Good", false),
                                        buildTableRow("3", "Fair", false),
                                        buildTableRow("2", "Poor", false),
                                        buildTableRow("1", "Bad", false),
                                    ],
                                ),
                            ),
                        ),
                        SizedBox(height: 5),
                    ],
                ),
            ),
        ),
    );
  }

  Widget buildTableRow(String score, String label, bool isHeader) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                  Text(score, style: TextStyle(
                      color: Colors.white,
                      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
                  Text(label, style: TextStyle(
                      color: Colors.white,
                      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
              ],
          ),
      );
  }

  Widget buildMetricsList() {
    return Padding(
      padding: const EdgeInsets.all(Constants.kPadding),
      child: Card(
        color: Constants.purpleLight,
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(Constants.kPadding),
          child: Column(
            children: widget.imagePaths.map((imagePath) => buildMetricTile(imagePath, scoreMap[imagePath])).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildMetricTile(String imagePath, double? score) {
    bool isCalculating = metricTiming[imagePath] == null;
    return ListTile(
      title: Text(
        "Score for $imagePath",
        style: TextStyle(
          fontFamily: 'Rastaglion',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white
        ),
      ),
      subtitle: Text(
          score != null ? (metricTiming[imagePath] == null ? "Recalculating..." : "$score - ${getQualityLevelMessage(score)}") : "No score calculated",
          style: TextStyle(
              fontFamily: 'TellMeAJoke',
              fontSize: 17,
              color: Colors.grey[400]
          ),
      ),
      trailing: isCalculating
        ? SizedBox(
            width: 60,  // Set a specific width for the SizedBox
            height: 20, // Set a specific height for the animation
            child: SpinKitThreeBounce(
              color: Colors.white,
              size: 20.0,
            ),
          )
        : Text(
            metricTiming[imagePath] ?? "Calculating...",
            style: TextStyle(color: Colors.grey[400]),
          ),
    );
  }
}
