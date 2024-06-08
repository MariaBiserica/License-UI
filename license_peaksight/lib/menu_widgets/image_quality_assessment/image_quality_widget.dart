import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/responsive_layout.dart';
import 'package:license_peaksight/menu_widgets/image_quality_assessment/panel_center_iqa.dart';
import 'package:license_peaksight/menu_widgets/image_quality_assessment/panel_left_iqa.dart';
import 'package:license_peaksight/menu_widgets/image_quality_assessment/panel_right_iqa.dart';
import 'package:provider/provider.dart';
import 'package:license_peaksight/theme_provider.dart';

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
    print("Selected metrics: $metrics");
    setState(() {
      selectedMetrics = metrics;
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
            height: 400,
            child: PanelLeftPage(
              onMetricsSelected: handleMetricsSelected,
              themeColors: themeColors,
            ),
          ),
          SizedBox(
            height: 500,
            child: PanelCenterPage(
              imagePath: widget.imagePath,
              selectedMetrics: selectedMetrics,
              themeColors: themeColors,
            ),
          ),
          SizedBox(
            height: 500,
            child: PanelRightPage(
              onImageSelected: widget.onImageSelected,
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
                child: PanelLeftPage(
                  onMetricsSelected: handleMetricsSelected,
                  themeColors: themeColors,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 210,
                child: PanelCenterPage(
                  imagePath: widget.imagePath,
                  selectedMetrics: selectedMetrics,
                  themeColors: themeColors,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 330,
          child: PanelRightPage(
            onImageSelected: widget.onImageSelected,
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
          child: PanelLeftPage(
            onMetricsSelected: handleMetricsSelected,
            themeColors: themeColors,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelCenterPage(
            imagePath: widget.imagePath,
            selectedMetrics: selectedMetrics,
            themeColors: themeColors,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelRightPage(
            onImageSelected: widget.onImageSelected,
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
          child: PanelLeftPage(
            onMetricsSelected: handleMetricsSelected,
            themeColors: themeColors,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelCenterPage(
            imagePath: widget.imagePath,
            selectedMetrics: selectedMetrics,
            themeColors: themeColors,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelRightPage(
            onImageSelected: widget.onImageSelected,
            themeColors: themeColors,
          ),
        ),
      ],
    );
  }
}
