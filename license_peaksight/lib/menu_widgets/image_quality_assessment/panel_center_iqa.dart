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
      DateTime startTime, endTime;
      final totalMetrics = widget.selectedMetrics.length;
      int completedMetrics = 0;

      final scores = await predictImageQuality(File(widget.imagePath), widget.selectedMetrics);
      endTime = DateTime.now();

      if (scores != null) {
        setState(() {
          // Assigning values directly based on whether they were requested
          if (widget.selectedMetrics.contains('Noise')) {
            startTime = DateTime.now();
            scoreMap['Noise'] = scores.noiseScore;
            endTime = DateTime.now();
            metricTiming['Noise'] = "${endTime.difference(startTime).inMilliseconds} ms";
            completedMetrics++;        
          }
          if (widget.selectedMetrics.contains('Contrast')) {
            startTime = DateTime.now();
            scoreMap['Contrast'] = scores.contrastScore;
            endTime = DateTime.now();
            metricTiming['Contrast'] = "${endTime.difference(startTime).inMilliseconds} ms";
            completedMetrics++;
          }
          if (widget.selectedMetrics.contains('Brightness')) {
            startTime = DateTime.now();
            scoreMap['Brightness'] = scores.brightnessScore;
            endTime = DateTime.now();
            metricTiming['Brightness'] = "${endTime.difference(startTime).inMilliseconds} ms";
            completedMetrics++;
          }
          if (widget.selectedMetrics.contains('Sharpness')) {
            startTime = DateTime.now();
            scoreMap['Sharpness'] = scores.sharpnessScore;
            endTime = DateTime.now();
            metricTiming['Sharpness'] = "${endTime.difference(startTime).inMilliseconds} ms";
            completedMetrics++;
          }
          if (widget.selectedMetrics.contains('Chromatic Quality')) {
            startTime = DateTime.now();
            scoreMap['Chromatic Quality'] = scores.chromaticScore;
            endTime = DateTime.now();
            metricTiming['Chromatic Quality'] = "${endTime.difference(startTime).inMilliseconds} ms";
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
            style: TextStyle(color: Colors.white),
        ),
        trailing: Text(
            metricTiming[metric] ?? "Calculating...",  // Display timing or a placeholder
            style: TextStyle(color: Colors.grey[400]),
        ),
    );
  }

}
