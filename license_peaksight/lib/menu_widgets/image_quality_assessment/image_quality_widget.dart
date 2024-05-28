import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/responsive_layout.dart';
import 'package:license_peaksight/menu_widgets/image_quality_assessment/panel_center_iqa.dart';
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
          SizedBox(height: 400, child: PanelLeftPage(onMetricsSelected: handleMetricsSelected)),
          SizedBox(height: 500, child: PanelCenterPage(imagePath: widget.imagePath, selectedMetrics: selectedMetrics)),
          SizedBox(height: 500, child: PanelRightPage(onImageSelected: widget.onImageSelected)),
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
            Expanded(child: SizedBox(height: 210, child: PanelLeftPage(onMetricsSelected: handleMetricsSelected))),
            Expanded(flex: 2, child: SizedBox(height: 210, child: PanelCenterPage(imagePath: widget.imagePath, selectedMetrics: selectedMetrics))),
          ],
        ),
        SizedBox(height: 330, child: PanelRightPage(onImageSelected: widget.onImageSelected)),
      ],
    );
  }

  // Build a custom layout for large tablet
  Widget _buildLargeTabletLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: PanelLeftPage(onMetricsSelected: handleMetricsSelected)),
        Expanded(flex: 3, child: PanelCenterPage(imagePath: widget.imagePath, selectedMetrics: selectedMetrics)),
        Expanded(flex: 3, child: PanelRightPage(onImageSelected: widget.onImageSelected)),
      ],
    );
  }

  // Build a custom layout for computer
  Widget _buildComputerLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: DrawerPage(onSectionSelected: widget.onSectionSelected)),
        Expanded(flex: 2, child: PanelLeftPage(onMetricsSelected: handleMetricsSelected)),
        Expanded(flex: 2, child: PanelCenterPage(imagePath: widget.imagePath, selectedMetrics: selectedMetrics)),
        Expanded(flex: 4, child: PanelRightPage(onImageSelected: widget.onImageSelected)),
      ],
    );
  }
}
