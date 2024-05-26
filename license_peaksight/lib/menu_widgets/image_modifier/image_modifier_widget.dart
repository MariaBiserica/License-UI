import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/menu_widgets/image_modifier/panel_center_modifier.dart';
import 'package:license_peaksight/menu_widgets/image_modifier/panel_left_modifier.dart';
import 'package:license_peaksight/menu_widgets/image_modifier/panel_right_modifier.dart';
import 'package:license_peaksight/responsive_layout.dart';

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
  String? modifiedImagePath;

  void handleMetricSelected(String? metric) {
    print("Selected metric: $metric"); // Debug print to check the callback
    setState(() {
      selectedMetric = metric; // Update the selected metric
    });

    if (metric == 'Spline Interpolation') {
      //modifyImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      tiny: Container(),
      phone: PanelCenterImageModifier(imagePath: modifiedImagePath),
      tablet: Row(
        children: [
          Expanded(child: PanelCenterImageModifier(imagePath: modifiedImagePath)),
        ],
      ),
      largeTablet: Row(
        children: [
          Expanded(flex: 2, child: PanelCenterImageModifier(imagePath: modifiedImagePath)),
          Expanded(flex: 3, child: PanelRightImageModifier(onImageSelected: widget.onImageSelected)),  
        ],
      ),
      computer: Row(
        children: [
          Expanded(flex: 2, child: DrawerPage(onSectionSelected: widget.onSectionSelected)),
          Expanded(flex: 2, child: PanelLeftImageModifier(onMetricSelected: handleMetricSelected)),
          Expanded(flex: 2, child: PanelCenterImageModifier(imagePath: modifiedImagePath)),
          Expanded(flex: 4, child: PanelRightImageModifier(onImageSelected: widget.onImageSelected)),
        ],
      ),
    );
  }
}
