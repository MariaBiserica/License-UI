import 'package:flutter/material.dart';
import 'package:license_peaksight/app_bar/app_bar_widget.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
// import 'package:license_peaksight/panel_center/panel_center_page.dart';
// import 'package:license_peaksight/panel_left/panel_left_page.dart';
// import 'package:license_peaksight/panel_right/panel_right_page.dart';
import 'package:license_peaksight/responsive_layout.dart';
import 'package:license_peaksight/menu_widgets/home_widget.dart';
import 'package:license_peaksight/menu_widgets/image_quality_widget.dart';

class WidgetTree extends StatefulWidget {
  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  String _imagePath = ''; // Holds the path of the selected image
  String _currentSection = 'Home'; // Default section

  // Function to be called when an image is selected in PanelRightPage
  void _onImageSelected(String imagePath) {
    setState(() {
      _imagePath = imagePath;
    });
  }

  void _onSectionSelected(String section) {
    print("Section selected: $section");
    setState(() {
      _currentSection = section;
    });
  }

  // Returns the appropriate widget based on the current section.
  Widget _getSectionWidget() {
    switch (_currentSection) {
      case 'Home':
        return HomeWidget(
            imagePath: _imagePath, onImageSelected: _onImageSelected,
            onSectionSelected: _onSectionSelected,
        ); // Your widget for Home
      case 'Image Quality Assessment':
        return ImageQualityWidget(
            imagePath: _imagePath, onImageSelected: _onImageSelected,
            onSectionSelected: _onSectionSelected,
        ); // Your widget for Image Quality Assessment
      // Add other cases for different sections here
      default:
        return HomeWidget(
          imagePath: _imagePath, onImageSelected: _onImageSelected,
            onSectionSelected: _onSectionSelected,
        ); // Default to HomeWidget
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, 100),
        child: (ResponsiveLayout.isTinyLimit(context) ||
                ResponsiveLayout.isTinyHeightLimit(context)
                ? Container() 
                : AppBarWidget(currentSection: _currentSection)),
      ),
      body: _getSectionWidget(),
      // ResponsiveLayout(
      //   tiny: Container(),
      //   phone: PanelCenterPage(imagePath: _imagePath),
      //   tablet: Row(
      //     children: [
      //       Expanded(child: PanelLeftPage(),),
      //       Expanded(child: PanelCenterPage(imagePath: _imagePath),),
      //     ],
      //   ),
      //   largeTablet: Row(
      //     children: [
      //       Expanded(
      //         flex: 2, // Adjust the flex factor to control size
      //         child: PanelLeftPage(),
      //       ),
      //       Expanded(
      //         flex: 2, // Adjust the flex factor to control size
      //         child: PanelCenterPage(imagePath: _imagePath),
      //       ),
      //       Expanded(
      //         flex: 3, // Give more space to the right panel
      //         child: PanelRightPage(onImageSelected: _onImageSelected), // Add the callback here
      //       ),
      //     ],
      //   ),
      //   computer: Row(
      //     children: [
      //       Expanded(
      //         flex: 2, // Drawer can remain with lesser space
      //         child: DrawerPage(),
      //       ),
      //       Expanded(
      //         flex: 2, // Adjust the flex factor to control size
      //         child: PanelLeftPage(),
      //       ),
      //       Expanded(
      //         flex: 2, // Adjust the flex factor to control size
      //         child: PanelCenterPage(imagePath: _imagePath),
      //       ),
      //       Expanded(
      //         flex: 4, // Give more space to the right panel
      //         child: PanelRightPage(onImageSelected: _onImageSelected), // Add the callback here
      //       ),
      //     ],
      //   ),
      // ),
      drawer: DrawerPage(onSectionSelected: _onSectionSelected),
    );
  }
}