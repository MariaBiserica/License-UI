import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/responsive_layout.dart';
import 'package:license_peaksight/menu_widgets/image_quality_assessment/panel_center_iqa.dart'; // Assuming this is used for displaying the main content
import 'package:license_peaksight/menu_widgets/image_quality_assessment/panel_left_iqa.dart';
import 'package:license_peaksight/menu_widgets/image_quality_assessment/panel_right_iqa.dart';

class ImageQualityWidget extends StatefulWidget {
  final String imagePath;
  final Function(String) onImageSelected;
  final Function(String) onSectionSelected;

  ImageQualityWidget({
    required this.imagePath,
    required this.onImageSelected,
    required this.onSectionSelected,
  });

  @override
  _ImageQualityWidgetState createState() => _ImageQualityWidgetState();
}

class _ImageQualityWidgetState extends State<ImageQualityWidget> {
  Set<String> selectedMetrics = {};

  void handleMetricsSelected(Set<String> metrics) {
    print("Selected metrics: $metrics"); // Debug print to check the callback
    setState(() {
      selectedMetrics = metrics; // Update the selected metrics
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      tiny: Container(),
      phone: PanelCenterPage(imagePath: widget.imagePath, selectedMetrics: selectedMetrics),
      tablet: Row(
        children: [
          Expanded(child: PanelCenterPage(imagePath: widget.imagePath, selectedMetrics: selectedMetrics)),
        ],
      ),
      largeTablet: Row(
        children: [
          Expanded(flex: 2, child: PanelCenterPage(imagePath: widget.imagePath, selectedMetrics: selectedMetrics)),
          Expanded(flex: 3, child: PanelRightPage(onImageSelected: widget.onImageSelected)),  
        ],
      ),
      computer: Row(
        children: [
          Expanded(flex: 2, child: DrawerPage(onSectionSelected: widget.onSectionSelected)),
          Expanded(flex: 2, child: PanelLeftPage(onMetricsSelected: handleMetricsSelected)),
          Expanded(flex: 2, child: PanelCenterPage(imagePath: widget.imagePath, selectedMetrics: selectedMetrics)),
          Expanded(flex: 4, child: PanelRightPage(onImageSelected: widget.onImageSelected)),
        ],
      ),
    );
  }
}
