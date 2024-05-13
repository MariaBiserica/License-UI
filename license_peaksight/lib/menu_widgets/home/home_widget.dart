import 'package:flutter/material.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/menu_widgets/home/panel_center_home.dart';
import 'package:license_peaksight/menu_widgets/home/panel_left_home.dart';
import 'package:license_peaksight/menu_widgets/home/panel_right_home.dart';
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
      phone: CenterPanelHome(), 
      tablet: Row(
        children: [
          Expanded(child: LeftPanelHome()),
          Expanded(flex: 2, child: CenterPanelHome()),
        ],
      ),
      largeTablet: Row(
        children: [
          Expanded(flex: 2, child: LeftPanelHome()),
          Expanded(flex: 2, child: CenterPanelHome()),
          Expanded(flex: 3, child: RightPanelHome()),  
        ],
      ),
      computer: Row(
        children: [
          Expanded(flex: 2, child: DrawerPage(onSectionSelected: onSectionSelected)),
          Expanded(flex: 2, child: LeftPanelHome()),
          Expanded(flex: 2, child: CenterPanelHome()),
          Expanded(flex: 4, child: RightPanelHome()),  
        ],
      ),
    );
  }
}
