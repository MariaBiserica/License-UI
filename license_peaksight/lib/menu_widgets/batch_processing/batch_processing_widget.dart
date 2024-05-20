import 'dart:io';

import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/menu_widgets/batch_processing/panel_center_batch.dart';
import 'package:license_peaksight/menu_widgets/batch_processing/panel_left_batch.dart';
import 'package:license_peaksight/menu_widgets/batch_processing/panel_right_batch.dart';
import 'package:license_peaksight/responsive_layout.dart';

class BatchProcessingWidget extends StatefulWidget {
  final Function(String) onImageSelected;
  final Function(String) onSectionSelected;

  BatchProcessingWidget({
    required this.onImageSelected,
    required this.onSectionSelected,
  });

  @override
  _BatchProcessingWidgetState createState() => _BatchProcessingWidgetState();
}

class _BatchProcessingWidgetState extends State<BatchProcessingWidget> {
  String selectedMetric = 'Noise'; // Default selected metric
  List<File> selectedImages = []; // Placeholder for the list of images to be processed

  void handleMetricSelected(String metric) {
    print("Selected metric: $metric"); // Debug print to check the callback
    setState(() {
      selectedMetric = metric; // Update the selected metric
    });
  }

  void handleImagesSelected(List<File> images) {
    print("Selected images: $images"); // Debug print to check the callback
    setState(() {
      selectedImages = images; // Update the list of selected images
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Building with ${selectedImages.length} images.");
    return ResponsiveLayout(
      tiny: Container(),
      phone: PanelLeftBatchProcessing(onMetricSelected: handleMetricSelected),
      tablet: Row(
        children: [
          Expanded(child: PanelCenterBatchProcessing(imageFiles: selectedImages, selectedMetric: selectedMetric)),
        ],
      ),
      largeTablet: Row(
        children: [
          Expanded(flex: 2, child: PanelCenterBatchProcessing(imageFiles: selectedImages, selectedMetric: selectedMetric)),
          Expanded(flex: 3, child: PanelRightBatchProcessing(onImagesSelected: handleImagesSelected)),  
        ],
      ),
      computer: Row(
        children: [
          Expanded(flex: 2, child: DrawerPage(onSectionSelected: widget.onSectionSelected)),
          Expanded(flex: 2, child: PanelLeftBatchProcessing(onMetricSelected: handleMetricSelected)),
          Expanded(flex: 2, child: PanelCenterBatchProcessing(imageFiles: selectedImages, selectedMetric: selectedMetric)),
          Expanded(flex: 4, child: PanelRightBatchProcessing(onImagesSelected: handleImagesSelected)),
        ],
      ),
    );
  }
}
