import 'dart:io';
import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/menu_widgets/batch_processing/panel_center_batch.dart';
import 'package:license_peaksight/menu_widgets/batch_processing/panel_left_batch.dart';
import 'package:license_peaksight/menu_widgets/batch_processing/panel_right_batch.dart';
import 'package:license_peaksight/responsive_layout.dart';

class BatchProcessingWidget extends StatefulWidget {
  final List<String> imagePaths;
  final Function(List<String>) onImagesSelected;
  final Function(String) onSectionSelected;

  BatchProcessingWidget({
    required this.imagePaths,
    required this.onImagesSelected,
    required this.onSectionSelected,
  });

  @override
  _BatchProcessingWidgetState createState() => _BatchProcessingWidgetState();
}

class _BatchProcessingWidgetState extends State<BatchProcessingWidget> {
  String selectedMetric = '';
  List<double> scores = []; // Add this to store the scores

  void handleMetricSelected(String metric) {
    print("Selected metric: $metric"); // Debug print to check the callback
    setState(() {
      selectedMetric = metric; // Update the selected metric
    });
  }

  void handleScoresCalculated(List<double> calculatedScores) {
    setState(() {
      scores = calculatedScores; // Update the scores when calculated
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      tiny: Container(),
      phone: PanelLeftBatchProcessing(
        onMetricSelected: handleMetricSelected,
        scores: scores, // Pass the scores to PanelLeftBatchProcessing
      ),
      tablet: Row(
        children: [
          Expanded(
            child: PanelCenterBatchProcessing(
              imagePaths: widget.imagePaths,
              selectedMetric: selectedMetric,
              onScoresCalculated: handleScoresCalculated, // Add this callback
            ),
          ),
        ],
      ),
      largeTablet: Row(
        children: [
          Expanded(
            flex: 2,
            child: PanelCenterBatchProcessing(
              imagePaths: widget.imagePaths,
              selectedMetric: selectedMetric,
              onScoresCalculated: handleScoresCalculated, // Add this callback
            ),
          ),
          Expanded(
            flex: 3,
            child: PanelRightBatchProcessing(onImagesSelected: widget.onImagesSelected),
          ),
        ],
      ),
      computer: Row(
        children: [
          Expanded(
            flex: 2,
            child: DrawerPage(onSectionSelected: widget.onSectionSelected),
          ),
          Expanded(
            flex: 2,
            child: PanelLeftBatchProcessing(
              onMetricSelected: handleMetricSelected,
              scores: scores, // Pass the scores to PanelLeftBatchProcessing
            ),
          ),
          Expanded(
            flex: 3,
            child: PanelCenterBatchProcessing(
              imagePaths: widget.imagePaths,
              selectedMetric: selectedMetric,
              onScoresCalculated: handleScoresCalculated, // Add this callback
            ),
          ),
          Expanded(
            flex: 2,
            child: PanelRightBatchProcessing(onImagesSelected: widget.onImagesSelected),
          ),
        ],
      ),
    );
  }
}
