import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:license_peaksight/constants.dart';
import '../../quality_assessment/get_quality_scores.dart';

class PanelCenterPage extends StatefulWidget {
  final String imagePath;
  final Set<String> selectedMetrics;

  PanelCenterPage({required this.imagePath, required this.selectedMetrics});

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
      final totalMetrics = widget.selectedMetrics.length;
      int completedMetrics = 0;

      final scores = await predictImageQuality(File(widget.imagePath), widget.selectedMetrics);

      if (scores != null) {
        setState(() {
          // Assigning values directly based on whether they were requested
          if (widget.selectedMetrics.contains('Noise')) {
            scoreMap['Noise'] = scores.noiseScore;
            metricTiming['Noise'] = "${scores.noiseTime}";
            completedMetrics++;        
          }
          if (widget.selectedMetrics.contains('Contrast')) {
            scoreMap['Contrast'] = scores.contrastScore;
            metricTiming['Contrast'] = "${scores.contrastTime}";
            completedMetrics++;
          }
          if (widget.selectedMetrics.contains('Brightness')) {
            scoreMap['Brightness'] = scores.brightnessScore;
            metricTiming['Brightness'] = "${scores.brightnessTime}";
            completedMetrics++;
          }
          if (widget.selectedMetrics.contains('Sharpness')) {
            scoreMap['Sharpness'] = scores.sharpnessScore;
            metricTiming['Sharpness'] = "${scores.sharpnessTime}";
            completedMetrics++;
          }
          if (widget.selectedMetrics.contains('Chromatic Quality')) {
            scoreMap['Chromatic Quality'] = scores.chromaticScore;
            metricTiming['Chromatic Quality'] = "${scores.chromaticTime}";
            completedMetrics++;
          }
          if (widget.selectedMetrics.contains('BRISQUE')) {
            scoreMap['BRISQUE'] = scores.brisqueScore;
            metricTiming['BRISQUE'] = "${scores.brisqueTime}";
            completedMetrics++;
          }
          if (widget.selectedMetrics.contains('ILNIQE')) {
            scoreMap['ILNIQE'] = scores.ilniqeScore;
            metricTiming['ILNIQE'] = "${scores.ilniqeTime}";
            completedMetrics++;
          }
          
          progress = completedMetrics / totalMetrics;
        });
      } else {
        // Show a dialog if the scores are null
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text("Failed to load quality scores. Please try again."),
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
                "Image quality assessment scores",
                style: TextStyle(color: Color.fromARGB(156, 158, 158, 158)),
              ),
              SizedBox(height: 16),  // Space between subtitle and progress bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Constants.panelForeground),
                minHeight: 10,  // Increase the height for better visibility
                borderRadius: BorderRadius.circular(10),
              ),
              SizedBox(height: 8),  // Space after progress bar
              if (progress > 0) Text(
                "Progress: ${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(color: Color.fromARGB(156, 158, 158, 158)),
              ),
            ],
          ),
        ),
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
            children: widget.selectedMetrics.map((metric) => buildMetricTile(metric, scoreMap[metric])).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildMetricTile(String metric, double? score) {
    return ListTile(
        title: Text(
            "Image $metric Score",
            style: TextStyle(color: Colors.white),
        ),
        subtitle: Text(
            score != null ? "$score - ${getQualityLevelMessage(score)}" : "No score calculated",
            style: TextStyle(color: Colors.grey[400]),
        ),
        trailing: Text(
            metricTiming[metric] ?? "Calculating...",  // Display timing or a placeholder
            style: TextStyle(color: Colors.grey[400]),
        ),
    );
  }

}
