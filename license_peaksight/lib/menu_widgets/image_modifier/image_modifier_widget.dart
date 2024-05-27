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
  List<Offset> controlPoints = [];

  void handleMetricSelected(String? metric) {
    print("Selected metric: $metric"); // Debug print to check the callback
    setState(() {
      selectedMetric = metric; // Update the selected metric
      if (metric == 'Spline Interpolation') {
        modifiedImagePathFuture = modifyImageSpline();
      } else if (metric == 'Gaussian Blur') {
        modifiedImagePathFuture = applyGaussianBlur(widget.imagePath);
      } else if (metric == 'Edge Detection') {
        modifiedImagePathFuture = applyEdgeDetection(widget.imagePath);
      } else if (metric == 'Color Space Conversion') {
        modifiedImagePathFuture = applyColorSpaceConversion(widget.imagePath);
      } else if (metric == 'Histogram Equalization') {
        modifiedImagePathFuture = applyHistogramEqualization(widget.imagePath);
      } else if (metric == 'Image Rotation') {
        modifiedImagePathFuture = applyImageRotation(widget.imagePath, 45); // Example angle
      }
    });
  }

  void handlePointsChanged(List<Offset> points) {
    setState(() {
      controlPoints = points;
    });
  }

  List<Map<String, int>> translateAndOrderPoints(List<Offset> points) {
    final translatedPoints = points.map((point) {
      final x = point.dx;
      final y = 255 - point.dy;
      return {'x': x.round(), 'y': y.round()};
    }).toList();

    translatedPoints.sort((a, b) => a['x']!.compareTo(b['x']!));
    return translatedPoints;
  }

  Future<String?> modifyImageSpline() async {
    final controlPointsMap = translateAndOrderPoints(controlPoints);

    print("Translated and ordered control points: $controlPointsMap");

    final filePath = await modifyImageSplineRequest(widget.imagePath, controlPointsMap);
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
          Expanded(flex: 2, child: PanelLeftImageModifier(onMetricSelected: handleMetricSelected, onPointsChanged: handlePointsChanged)),
          Expanded(flex: 3, child: PanelCenterImageModifier(imagePathFuture: modifiedImagePathFuture)),
          Expanded(flex: 3, child: PanelRightImageModifier(onImageSelected: widget.onImageSelected)),
        ],
      ),
    );
  }
}
