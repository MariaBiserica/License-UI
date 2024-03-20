import 'package:flutter/material.dart';
import 'package:license_peaksight/app_bar/app_bar_widget.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/panel_center/panel_center_page.dart';
import 'package:license_peaksight/panel_left/panel_left_page.dart';
import 'package:license_peaksight/panel_right/panel_right_page.dart';
import 'package:license_peaksight/responsive_layout.dart';

class WidgetTree extends StatefulWidget {
  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        child: (ResponsiveLayout.isTinyLimit(context) ||
                ResponsiveLayout.isTinyHeightLimit(context) 
                ? Container() 
                : AppBarWidget()),
        preferredSize: Size(double.infinity, 100),
      ),
      body: ResponsiveLayout(
        tiny: Container(),
        phone: PanelCenterPage(),
        tablet: Row(
          children: [
            Expanded(child: PanelLeftPage(),),
            Expanded(child: PanelCenterPage(),),
          ],
        ),
        largeTablet: Row(
          children: [
            Expanded(
              flex: 2, // Adjust the flex factor to control size
              child: PanelLeftPage(),
            ),
            Expanded(
              flex: 2, // Adjust the flex factor to control size
              child: PanelCenterPage(),
            ),
            Expanded(
              flex: 3, // Give more space to the right panel
              child: PanelRightPage(),
            ),
          ],
        ),
        computer: Row(
          children: [
            Expanded(
              flex: 2, // Drawer can remain with lesser space
              child: DrawerPage(),
            ),
            Expanded(
              flex: 2, // Adjust the flex factor to control size
              child: PanelLeftPage(),
            ),
            Expanded(
              flex: 2, // Adjust the flex factor to control size
              child: PanelCenterPage(),
            ),
            Expanded(
              flex: 4, // Give more space to the right panel
              child: PanelRightPage(),
            ),
          ],
        ),
      ),
      drawer: DrawerPage(),
    );
  }
}
