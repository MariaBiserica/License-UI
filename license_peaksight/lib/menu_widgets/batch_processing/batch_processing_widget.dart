import 'dart:io';
import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/menu_widgets/batch_processing/panel_center_batch.dart';
import 'package:license_peaksight/menu_widgets/batch_processing/panel_left_batch.dart';
import 'package:license_peaksight/menu_widgets/batch_processing/panel_right_batch.dart';
import 'package:license_peaksight/responsive_layout.dart';
import 'package:provider/provider.dart';
import 'package:license_peaksight/theme_provider.dart';

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
  List<double> scores = [];

  void handleMetricSelected(String metric) {
    print("Selected metric: $metric");
    setState(() {
      selectedMetric = metric;
    });
  }

  void handleScoresCalculated(List<double> calculatedScores) {
    setState(() {
      scores = calculatedScores;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeColors = themeProvider.themeColors;

    return ResponsiveLayout(
      tiny: _buildScrollableColumnLayout(themeColors),
      phone: _buildScrollableColumnLayout(themeColors),
      tablet: _buildTabletLayout(themeColors),
      largeTablet: _buildLargeTabletLayout(themeColors),
      computer: _buildComputerLayout(themeColors),
    );
  }

  Widget _buildScrollableColumnLayout(Map<String, Color> themeColors) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: PanelLeftBatchProcessing(
              onMetricSelected: handleMetricSelected,
              scores: scores,
              imagePaths: widget.imagePaths,
              themeColors: themeColors,
            ),
          ),
          SizedBox(
            height: 500,
            child: PanelCenterBatchProcessing(
              imagePaths: widget.imagePaths,
              selectedMetric: selectedMetric,
              onScoresCalculated: handleScoresCalculated,
              themeColors: themeColors,
            ),
          ),
          SizedBox(
            height: 500,
            child: PanelRightBatchProcessing(
              onImagesSelected: widget.onImagesSelected,
              themeColors: themeColors,
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(Map<String, Color> themeColors) {
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
                  themeColors: themeColors,
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
                  themeColors: themeColors,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 330,
          child: PanelRightBatchProcessing(
            onImagesSelected: widget.onImagesSelected,
            themeColors: themeColors,
          ),
        ),
      ],
    );
  }

  Widget _buildLargeTabletLayout(Map<String, Color> themeColors) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PanelLeftBatchProcessing(
            onMetricSelected: handleMetricSelected,
            scores: scores,
            imagePaths: widget.imagePaths,
            themeColors: themeColors,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelCenterBatchProcessing(
            imagePaths: widget.imagePaths,
            selectedMetric: selectedMetric,
            onScoresCalculated: handleScoresCalculated,
            themeColors: themeColors,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelRightBatchProcessing(
            onImagesSelected: widget.onImagesSelected,
            themeColors: themeColors,
          ),
        ),
      ],
    );
  }

  Widget _buildComputerLayout(Map<String, Color> themeColors) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DrawerPage(
            onSectionSelected: widget.onSectionSelected,
          ),
        ),
        Expanded(
          flex: 2,
          child: PanelLeftBatchProcessing(
            onMetricSelected: handleMetricSelected,
            scores: scores,
            imagePaths: widget.imagePaths,
            themeColors: themeColors,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelCenterBatchProcessing(
            imagePaths: widget.imagePaths,
            selectedMetric: selectedMetric,
            onScoresCalculated: handleScoresCalculated,
            themeColors: themeColors,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelRightBatchProcessing(
            onImagesSelected: widget.onImagesSelected,
            themeColors: themeColors,
          ),
        ),
      ],
    );
  }
}
