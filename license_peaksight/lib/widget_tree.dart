import 'package:flutter/material.dart';
import 'package:license_peaksight/app_bar/app_bar_widget.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/responsive_layout.dart';
import 'package:license_peaksight/menu_widgets/home/home_widget.dart';
import 'package:license_peaksight/menu_widgets/image_quality_assessment/image_quality_widget.dart';

class WidgetTree extends StatefulWidget {
  final String? userAvatarUrl;

  WidgetTree({this.userAvatarUrl});

  @override
  _WidgetTreeState createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  String _imagePath = ''; // Holds the path of the selected image
  String _currentSection = 'Home'; // Default section
  Set<String> _selectedMetrics = {}; // For the IQA widget

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

  void _onMetricsSelected(Set<String> metrics) {
    setState(() => _selectedMetrics = metrics);
  }

  // Returns the appropriate widget based on the current section.
  Widget _getSectionWidget() {
    switch (_currentSection) {
      case 'Home':
        return HomeWidget(
            imagePath: _imagePath, onImageSelected: _onImageSelected,
            onSectionSelected: _onSectionSelected,
        ); // My widget for Home
      case 'Image Quality Assessment':
        return ImageQualityWidget(
            imagePath: _imagePath, 
            onImageSelected: _onImageSelected,
            onSectionSelected: _onSectionSelected,
        ); // My widget for Image Quality Assessment
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
                : AppBarWidget(avatarUrl: widget.userAvatarUrl,)),
      ),
      body: _getSectionWidget(),
      drawer: DrawerPage(onSectionSelected: _onSectionSelected),
    );
  }
}