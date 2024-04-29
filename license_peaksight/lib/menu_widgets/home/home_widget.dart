import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/menu_widgets/home/center_panel_home.dart';
import 'package:license_peaksight/menu_widgets/home/left_panel_home.dart';
import 'package:license_peaksight/menu_widgets/home/right_panel_home.dart';
import 'package:license_peaksight/panel_center/panel_center_page.dart';
import 'package:license_peaksight/responsive_layout.dart';

class HomeWidget extends StatelessWidget {
  final String imagePath;
  final Function(String) onImageSelected;
  final Function(String) onSectionSelected; // New callback for section changes

  // Modify the constructor to accept the new callback
  HomeWidget({
    required this.imagePath,
    required this.onImageSelected,
    required this.onSectionSelected, // Require the callback in the constructor
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      tiny: Container(),
      phone: PanelCenterPage(imagePath: imagePath),  // Assuming this is your main panel for the Home section
      tablet: Row(
        children: [
          Expanded(child: LeftPanelHome()),
          Expanded(flex: 2, child: CenterPanelHome()),
         //Expanded(child: PanelCenterPage(imagePath: imagePath)),
        ],
      ),
      largeTablet: Row(
        children: [
          Expanded(flex: 2, child: LeftPanelHome()),
          Expanded(flex: 2, child: CenterPanelHome()),
          //Expanded(flex: 2, child: PanelCenterPage(imagePath: imagePath)),
          //Expanded(flex: 3, child: PanelRightPage(onImageSelected: onImageSelected)),
          Expanded(flex: 3, child: RightPanelHome()),  
        ],
      ),
      computer: Row(
        children: [
          Expanded(flex: 2, child: DrawerPage(onSectionSelected: onSectionSelected)),
          Expanded(flex: 2, child: LeftPanelHome()),
          Expanded(flex: 2, child: CenterPanelHome()),
          //Expanded(flex: 2, child: PanelCenterPage(imagePath: imagePath)),
          //Expanded(flex: 4, child: PanelRightPage(onImageSelected: onImageSelected)),
          Expanded(flex: 4, child: RightPanelHome()),  
        ],
      ),
    );
  }
}
