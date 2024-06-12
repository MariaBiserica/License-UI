import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/menu_widgets/image_modifier/panel_center_modifier.dart';
import 'package:license_peaksight/menu_widgets/image_modifier/panel_left_modifier.dart';
import 'package:license_peaksight/menu_widgets/image_modifier/panel_right_modifier.dart';
import 'package:license_peaksight/responsive_layout.dart';
import 'package:license_peaksight/server_requests/image_modifier_service.dart';
import 'package:provider/provider.dart';
import 'package:license_peaksight/theme_provider.dart';

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
  double rotationAngle = 45.0;
  double blurAmount = 15.0;
  String selectedColorSpace = 'HSV';
  String morphOperation = 'dilation';
  int kernelSize = 3;
  double hueScalar = 1.0;
  double saturationScalar = 1.0;
  double valueScalar = 1.0;

  void handleMetricSelected(String? metric, [Map<String, dynamic>? options]) {
    print("Selected metric: $metric"); // Debug print to check the callback
    setState(() {
      selectedMetric = metric; // Update the selected metric
      if (options != null) {
        rotationAngle = options['angle'] ?? rotationAngle; // Update the rotation angle if provided
        blurAmount = options['blurAmount'] ?? blurAmount; // Update the blur amount if provided
        selectedColorSpace = options['colorSpace'] ?? selectedColorSpace; // Update the color space if provided
        morphOperation = options['operation'] ?? morphOperation;
        kernelSize = options['kernelSize'] ?? kernelSize;
        hueScalar = options['hueScalar'] ?? hueScalar;
        saturationScalar = options['saturationScalar'] ?? saturationScalar;
        valueScalar = options['valueScalar'] ?? valueScalar;
      }

      if (metric == 'Curves Adjustment') {
        modifiedImagePathFuture = modifyImageSpline();
      } else if (metric == 'Gaussian Blur') {
        modifiedImagePathFuture = applyGaussianBlur(widget.imagePath, blurAmount);
      } else if (metric == 'Edge Detection') {
        modifiedImagePathFuture = applyEdgeDetection(widget.imagePath);
      } else if (metric == 'Color Space Conversion') {
        modifiedImagePathFuture = applyColorSpaceConversion(widget.imagePath, selectedColorSpace);
      } else if (metric == 'Histogram Equalization') {
        modifiedImagePathFuture = applyHistogramEqualization(widget.imagePath);
      } else if (metric == 'Image Rotation') {
        modifiedImagePathFuture = applyImageRotation(widget.imagePath, rotationAngle);
      } else if (metric == 'Morphological Transformation') {
        modifiedImagePathFuture = applyMorphologicalTransformation(widget.imagePath, morphOperation, kernelSize);
      } else if (metric == 'Inverse Color') {
        modifiedImagePathFuture = applyInverseColor(widget.imagePath);
      } else if (metric == 'Color Enhancement') {
        modifiedImagePathFuture = applyColorEnhancement(widget.imagePath, hueScalar, saturationScalar, valueScalar);
      } else if (metric == 'Sharpening') {
        modifiedImagePathFuture = applySharpening(widget.imagePath, kernelSize);
      } else if (metric == 'Median Blur') {
        modifiedImagePathFuture = applyMedianBlur(widget.imagePath, kernelSize);
      } else if (metric == 'Noise Reduction') {
        modifiedImagePathFuture = applyNoiseReduction(widget.imagePath);
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
            child: PanelLeftImageModifier(
              onMetricSelected: handleMetricSelected,
              onPointsChanged: handlePointsChanged,
              themeColors: themeColors,
            ),
          ),
          SizedBox(
            height: 500,
            child: PanelCenterImageModifier(
              imagePathFuture: modifiedImagePathFuture,
              themeColors: themeColors,
            ),
          ),
          SizedBox(
            height: 500,
            child: PanelRightImageModifier(
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
                child: PanelLeftImageModifier(
                  onMetricSelected: handleMetricSelected,
                  onPointsChanged: handlePointsChanged,
                  themeColors: themeColors,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 210,
                child: PanelCenterImageModifier(
                  imagePathFuture: modifiedImagePathFuture,
                  themeColors: themeColors,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 330,
          child: PanelRightImageModifier(
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
          child: PanelLeftImageModifier(
            onMetricSelected: handleMetricSelected,
            onPointsChanged: handlePointsChanged,
            themeColors: themeColors,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelCenterImageModifier(
            imagePathFuture: modifiedImagePathFuture,
            themeColors: themeColors,
          ),
        ),
        Expanded(
          flex: 3,
          child: PanelRightImageModifier(
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
          child: PanelLeftImageModifier(
            onMetricSelected: handleMetricSelected,
            onPointsChanged: handlePointsChanged,
            themeColors: themeColors,
          ),
        ),
        Expanded(
          flex: 2,
          child: PanelCenterImageModifier(
            imagePathFuture: modifiedImagePathFuture,
            themeColors: themeColors,
          ),
        ),
        Expanded(
          flex: 2,
          child: PanelRightImageModifier(
            onImageSelected: widget.onImageSelected,
            themeColors: themeColors,
          ),
        ),
      ],
    );
  }
}
