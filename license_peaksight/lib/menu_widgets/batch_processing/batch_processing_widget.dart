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
      tiny: _buildScrollableColumnLayout(), // Single column for tiny layout
      phone: _buildScrollableColumnLayout(), // Single column for phone layout
      tablet: _buildTabletLayout(), // Custom layout for tablet
      largeTablet: _buildLargeTabletLayout(), // Side by side layout for large tablet
      computer: _buildComputerLayout(), // Side by side layout for computer
    );
  }

  // Build a scrollable column layout for tiny and phone
  Widget _buildScrollableColumnLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PanelLeftBatchProcessing(
              onMetricSelected: handleMetricSelected,
              scores: scores,
              imagePaths: widget.imagePaths,
            ),
          ),
          SizedBox(
            height: 500,
            child: PanelCenterBatchProcessing(
              imagePaths: widget.imagePaths,
              selectedMetric: selectedMetric,
              onScoresCalculated: handleScoresCalculated,
            ),
          ),
          SizedBox(
            height: 500,
            child: PanelRightBatchProcessing(
              onImagesSelected: widget.onImagesSelected,
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  // Build a custom layout for tablet
  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 210,
                child: PanelLeftBatchProcessing(
                  onMetricSelected: handleMetricSelected,
                  scores: scores,
                  imagePaths: widget.imagePaths,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 210,
                child: PanelCenterBatchProcessing(
                  imagePaths: widget.imagePaths,
                  selectedMetric: selectedMetric,
                  onScoresCalculated: handleScoresCalculated,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 330,
          child: PanelRightBatchProcessing(
            onImagesSelected: widget.onImagesSelected,
          ),
        ),
      ],
    );
  }

  // Build a custom layout for large tablet
  Widget _buildLargeTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PanelLeftBatchProcessing(
            onMetricSelected: handleMetricSelected,
            scores: scores,
            imagePaths: widget.imagePaths,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelCenterBatchProcessing(
            imagePaths: widget.imagePaths,
            selectedMetric: selectedMetric,
            onScoresCalculated: handleScoresCalculated,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelRightBatchProcessing(
            onImagesSelected: widget.onImagesSelected,
          ),
        ),
      ],
    );
  }

  // Build a custom layout for computer
  Widget _buildComputerLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DrawerPage(onSectionSelected: widget.onSectionSelected),
        ),
        Expanded(
          flex: 2,
          child: PanelLeftBatchProcessing(
            onMetricSelected: handleMetricSelected,
            scores: scores,
            imagePaths: widget.imagePaths,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelCenterBatchProcessing(
            imagePaths: widget.imagePaths,
            selectedMetric: selectedMetric,
            onScoresCalculated: handleScoresCalculated,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelRightBatchProcessing(
            onImagesSelected: widget.onImagesSelected,
          ),
        ),
      ],
    );
  }
}
