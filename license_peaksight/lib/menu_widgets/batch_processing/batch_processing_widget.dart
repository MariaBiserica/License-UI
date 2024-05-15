import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/menu_widgets/batch_processing/panel_left_batch.dart';
import 'package:license_peaksight/menu_widgets/batch_processing/panel_right_batch.dart';
import 'package:license_peaksight/responsive_layout.dart';

class BatchProcessingWidget extends StatefulWidget {
  final String imagePath;
  final Function(String) onImageSelected;
  final Function(String) onSectionSelected;

  BatchProcessingWidget({
    required this.imagePath,
    required this.onImageSelected,
    required this.onSectionSelected,
  });

  @override
  _BatchProcessingWidgetState createState() => _BatchProcessingWidgetState();
}

class _BatchProcessingWidgetState extends State<BatchProcessingWidget> {
  String selectedMetric = 'Noise'; // Default selected metric

  void handleMetricSelected(String metric) {
    print("Selected metric: $metric"); // Debug print to check the callback
    setState(() {
      selectedMetric = metric; // Update the selected metric
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      tiny: Container(),
      phone: PanelLeftBatchProcessing(onMetricSelected: handleMetricSelected),
      tablet: Row(
        children: [
          //Expanded(child: PanelCenterPage(imagePath: widget.imagePath, selectedMetrics: selectedMetrics)),
        ],
      ),
      largeTablet: Row(
        children: [
          //Expanded(flex: 2, child: PanelCenterPage(imagePath: widget.imagePath, selectedMetrics: selectedMetrics)),
          Expanded(flex: 3, child: PanelRightBatchProcessing(onImageSelected: widget.onImageSelected)),  
        ],
      ),
      computer: Row(
        children: [
          Expanded(flex: 2, child: DrawerPage(onSectionSelected: widget.onSectionSelected)),
          Expanded(flex: 2, child: PanelLeftBatchProcessing(onMetricSelected: handleMetricSelected)),
          //Expanded(flex: 2, child: PanelCenterPage(imagePath: widget.imagePath, selectedMetrics: selectedMetrics)),
          Expanded(flex: 4, child: PanelRightBatchProcessing(onImageSelected: widget.onImageSelected)),
        ],
      ),
    );
  }
}
