import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/menu_widgets/image_modifier/panel_center_modifier.dart';
import 'package:license_peaksight/menu_widgets/image_modifier/panel_left_modifier.dart';
import 'package:license_peaksight/menu_widgets/image_modifier/panel_right_modifier.dart';
import 'package:license_peaksight/responsive_layout.dart';
import 'package:license_peaksight/server_requests/image_modifier_service.dart';

class ImageModifierWidget extends StatefulWidget {
  final String imagePath;
  final Function(String) onImageSelected;
  final Function(String) onSectionSelected;

  ImageModifierWidget({
    required this.imagePath,
    required this.onImageSelected,
    required this.onSectionSelected,
  });

  @override
  _ImageModifierWidgetState createState() => _ImageModifierWidgetState();
}

class _ImageModifierWidgetState extends State<ImageModifierWidget> {
  String? selectedMetric;
  Future<String?>? modifiedImagePathFuture;

  void handleMetricSelected(String? metric) {
    print("Selected metric: $metric"); // Debug print to check the callback
    setState(() {
      selectedMetric = metric; // Update the selected metric
      if (metric == 'Spline Interpolation') {
        modifiedImagePathFuture = modifyImageSpline();
      }
    });
  }

  Future<String?> modifyImageSpline() async {
    final controlPoints = [
      {'x': 0, 'y': 0},
      {'x': 111, 'y': 33},
      {'x': 185, 'y': 118},
      {'x': 255, 'y': 255}
    ];

    final filePath = await modifyImageSplineRequest(widget.imagePath, controlPoints);
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      tiny: Container(),
      phone: PanelCenterImageModifier(imagePathFuture: modifiedImagePathFuture),
      tablet: Row(
        children: [
          Expanded(child: PanelCenterImageModifier(imagePathFuture: modifiedImagePathFuture)),
        ],
      ),
      largeTablet: Row(
        children: [
          Expanded(flex: 2, child: PanelCenterImageModifier(imagePathFuture: modifiedImagePathFuture)),
          Expanded(flex: 3, child: PanelRightImageModifier(onImageSelected: widget.onImageSelected)),  
        ],
      ),
      computer: Row(
        children: [
          Expanded(flex: 2, child: DrawerPage(onSectionSelected: widget.onSectionSelected)),
          Expanded(flex: 2, child: PanelLeftImageModifier(onMetricSelected: handleMetricSelected)),
          Expanded(flex: 3, child: PanelCenterImageModifier(imagePathFuture: modifiedImagePathFuture)),
          Expanded(flex: 3, child: PanelRightImageModifier(onImageSelected: widget.onImageSelected)),
        ],
      ),
    );
  }
}
