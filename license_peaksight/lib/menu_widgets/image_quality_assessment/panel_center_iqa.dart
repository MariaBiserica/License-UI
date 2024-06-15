import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:license_peaksight/constants.dart';
import '../../server_requests/get_quality_scores.dart';

class PanelCenterPage extends StatefulWidget {
  final String imagePath;
  final Set<String> selectedMetrics;
  final Map<String, Color> themeColors;

  PanelCenterPage({
    required this.imagePath,
    required this.selectedMetrics,
    required this.themeColors,
  });

  @override
  _PanelCenterPageState createState() => _PanelCenterPageState();
}

class _PanelCenterPageState extends State<PanelCenterPage> {
  Map<String, double?> scoreMap = {};
  double progress = 0.0;
  Map<String, String> metricTiming = {};

  @override
  void didUpdateWidget(covariant PanelCenterPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMetrics != oldWidget.selectedMetrics) {
      // Reset progress and initiate a new calculation
      progress = 0.0;
      metricTiming.clear();
      calculateQualityScores();  // Recalculate scores if selected metrics change
    }
  }

  void calculateQualityScores() async {
    if (widget.imagePath.isNotEmpty && widget.selectedMetrics.isNotEmpty) {
      final scores = await predictImageQuality(File(widget.imagePath), widget.selectedMetrics);

      if (scores != null) {
        setState(() {
          // Assigning values directly based on whether they were requested
          if (widget.selectedMetrics.contains('Noise')) {
            scoreMap['Noise'] = scores.noiseScore;
            metricTiming['Noise'] = "${scores.noiseTime}";
          }
          if (widget.selectedMetrics.contains('Contrast')) {
            scoreMap['Contrast'] = scores.contrastScore;
            metricTiming['Contrast'] = "${scores.contrastTime}";
          }
          if (widget.selectedMetrics.contains('Brightness')) {
            scoreMap['Brightness'] = scores.brightnessScore;
            metricTiming['Brightness'] = "${scores.brightnessTime}";
          }
          if (widget.selectedMetrics.contains('Sharpness')) {
            scoreMap['Sharpness'] = scores.sharpnessScore;
            metricTiming['Sharpness'] = "${scores.sharpnessTime}";
          }
          if (widget.selectedMetrics.contains('Chromatic Quality')) {
            scoreMap['Chromatic Quality'] = scores.chromaticScore;
            metricTiming['Chromatic Quality'] = "${scores.chromaticTime}";
          }
          if (widget.selectedMetrics.contains('BRISQUE')) {
            scoreMap['BRISQUE'] = scores.brisqueScore;
            metricTiming['BRISQUE'] = "${scores.brisqueTime}";
          }
          if (widget.selectedMetrics.contains('NIQE')) {
            scoreMap['NIQE'] = scores.niqeScore;
            metricTiming['NIQE'] = "${scores.niqeTime}";
          }
          if (widget.selectedMetrics.contains('ILNIQE')) {
            scoreMap['ILNIQE'] = scores.ilniqeScore;
            metricTiming['ILNIQE'] = "${scores.ilniqeTime}";
          }
          if (widget.selectedMetrics.contains('VGG16')) {
            scoreMap['VGG16'] = scores.vgg16Score;
            metricTiming['VGG16'] = "${scores.vgg16Time}";
          }
          if (widget.selectedMetrics.contains('BIQA Noise Stats')) {
            scoreMap['BIQA Noise Stats'] = scores.biqaScore;
            metricTiming['BIQA Noise Stats'] = "${scores.biqaTime}";
          }
          
        });
      } else {
        // Show a dialog if the scores are null
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Warning"),
              content: Text("Caught an exception while fetching data. Please try again if necessary."),
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

  String getQualityLevelMessage(double? score) {
    if (score == null) return "No score calculated";
    if (score > 5 || score < 1) return "Outlier";
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
            color: widget.themeColors['panelBackground'],
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
                            fontFamily: 'HeaderFont', 
                              fontSize: 35, 
                              color: widget.themeColors['textColor'],
                              shadows: <Shadow>[
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                        ),
                        SizedBox(height: 8),  // Space between title and subtitle
                        Text(
                            "Image quality MOS scale scores",
                            style: TextStyle(
                              fontSize: 16,
                              color: widget.themeColors['subtitleColor'],
                            ),
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
                      color: widget.themeColors['textColor'],
                      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
                  Text(label, style: TextStyle(
                      color: widget.themeColors['textColor'],
                      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
              ],
          ),
      );
  }

  Widget buildMetricsList() {
    return Padding(
      padding: const EdgeInsets.all(Constants.kPadding),
      child: Card(
        color: widget.themeColors['panelBackground'],
        elevation: 3,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(Constants.kPadding),
          child: Column(
            children: widget.selectedMetrics.map((metric) => buildMetricTile(metric, scoreMap[metric])).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildMetricTile(String metric, double? score) {
    bool isCalculating = metricTiming[metric] == null;
    return ListTile(
      title: Text(
        "$metric Score",
        style: TextStyle(
          fontFamily: 'Rastaglion',
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: widget.themeColors['textColor'],
        ),
      ),
      subtitle: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: widget.themeColors['subtitleBackgroundColor'], // Add background color
          borderRadius: BorderRadius.circular(10), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 254, 254, 255).withOpacity(0.3), // Shadow color with opacity
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 3), // Offset the shadow
            ),
          ],
        ),
        child: Text(
          score != null ? (metricTiming[metric] == null ? "Recalculating..." : "$score - ${getQualityLevelMessage(score)}") : "No score calculated",
          style: TextStyle(
            fontFamily: 'TellMeAJoke',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: widget.themeColors['scoresColor'],
          ),
        ),
      ),
      trailing: isCalculating
        ? SizedBox(
            width: 60,  // Set a specific width for the SizedBox
            height: 20, // Set a specific height for the animation
            child: SpinKitThreeBounce(
              color: widget.themeColors['textColor'],
              size: 20.0,
            ),
          )
        : Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: widget.themeColors['trailingBackgroundColor'], // Add background color
              borderRadius: BorderRadius.circular(10), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Shadow color with opacity
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3), // Offset the shadow
                ),
              ],
            ),
            child: Text(
              metricTiming[metric] ?? "Calculating...",
              style: TextStyle(
                color: widget.themeColors['textColor'], 
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
          ),
    );
  }

}
