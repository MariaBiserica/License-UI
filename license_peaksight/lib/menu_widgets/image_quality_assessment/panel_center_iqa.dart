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

  @override
  void didUpdateWidget(covariant PanelCenterPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMetrics != oldWidget.selectedMetrics) {
      calculateQualityScores();  // Recalculate scores if selected metrics change
    }
  }

  void calculateQualityScores() async {
    if (widget.imagePath.isNotEmpty) {
      final scores = await predictImageQuality(File(widget.imagePath), widget.selectedMetrics);
      setState(() {
        // Update scores based on the selected metrics
        scoreMap = {
          'Noise': scores.noiseScore,
          'Contrast': scores.contrastScore,
          'Brightness': scores.brightnessScore,
          'Sharpness': scores.sharpnessScore,
          'Chromatic Quality': scores.chromaticScore,
        };
      });
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
              "Analysis Overview",
              style: TextStyle(
                fontFamily: 'MOXABestine',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white
              ), 
            ),
            subtitle: Text(
              "Image quality assessment scores",
              style: TextStyle(color: Color.fromARGB(156, 158, 158, 158)),
            ),
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
    );
  }
}
