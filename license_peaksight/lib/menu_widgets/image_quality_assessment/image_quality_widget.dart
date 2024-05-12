import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/panel_left/panel_left_page.dart';
import 'package:license_peaksight/responsive_layout.dart';
import 'package:license_peaksight/panel_center/panel_center_page.dart'; // Assuming this is used for displaying the main content
import 'package:license_peaksight/menu_widgets/image_quality_assessment/panel_right_page.dart'; // Assuming this is used for image upload

class ImageQualityWidget extends StatelessWidget {
  final String imagePath;
  final Function(String) onImageSelected;
  final Function(String) onSectionSelected; // New callback for section changes

  // Modify the constructor to accept the new callback
  ImageQualityWidget({
    required this.imagePath,
    required this.onImageSelected,
    required this.onSectionSelected, // Require the callback in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      tiny: Container(),
      phone: PanelCenterPage(imagePath: imagePath),  // Assuming this is your main content area for the Image Quality Assessment section
      tablet: Row(
        children: [
          Expanded(child: PanelCenterPage(imagePath: imagePath)),
        ],
      ),
      largeTablet: Row(
        children: [
          Expanded(flex: 2, child: PanelCenterPage(imagePath: imagePath)),
          Expanded(flex: 3, child: PanelRightPage(onImageSelected: onImageSelected)),  
        ],
      ),
      computer: Row(
        children: [
          Expanded(flex: 2, child: DrawerPage(onSectionSelected: onSectionSelected)),
          Expanded(flex: 2, child: PanelLeftPage()),
          Expanded(flex: 2, child: PanelCenterPage(imagePath: imagePath)),
          Expanded(flex: 4, child: PanelRightPage(onImageSelected: onImageSelected)),  // For uploading and selecting images
        ],
      ),
    );
  }
}
