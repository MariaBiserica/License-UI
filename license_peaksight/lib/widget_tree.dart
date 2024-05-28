import 'package:flutter/material.dart';
import 'package:license_peaksight/app_bar/app_bar_widget.dart';
import 'package:license_peaksight/app_bar/notification_service.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/menu_widgets/batch_processing/batch_processing_widget.dart';
import 'package:license_peaksight/menu_widgets/home/panel_right_home.dart';
import 'package:license_peaksight/menu_widgets/image_modifier/image_modifier_widget.dart';
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
  List<String> _imagePaths = []; // Holds the paths of the selected images
  String _currentSection = 'Home'; // Default section
  Set<String> _selectedMetrics = {}; // For the IQA widget
  final ValueNotifier<List<NotificationCustom>> _notifications = ValueNotifier([]); // Manage notifications state

  final GlobalKey<RightPanelHomeState> _rightPanelKey = GlobalKey<RightPanelHomeState>();

  // Function to be called when an image is selected in PanelRightPage
  void _onImageSelected(String imagePath) {
    setState(() {
      _imagePath = imagePath;
    });
  }

  void _onImagesSelected(List<String> imagePaths) {
    setState(() {
      _imagePaths = imagePaths;
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

  // Handle the restoration of tasks
  void _handleRestore(NotificationCustom notification) {
    _notifications.value = List.from(_notifications.value)..remove(notification); // Remove notification after restoration
    
    // Find the RightPanelHome and restore the task
    _rightPanelKey.currentState?.restoreTask(notification.task);
  }

  // Handle the clearing of notifications
  void _handleClearNotifications() {
    setState(() {
      _notifications.value = [];
    });
  }

  // Returns the appropriate widget based on the current section.
  Widget _getSectionWidget() {
    switch (_currentSection) {
      case 'Home':
        return HomeWidget(
            imagePath: _imagePath, 
            onImageSelected: _onImageSelected,
            onSectionSelected: _onSectionSelected,
            notifications: _notifications,
            onRestore: _handleRestore, // Pass the callback to HomeWidget
            rightPanelKey: _rightPanelKey,
        ); // My widget for Home
      case 'Image Quality Assessment':
        return ImageQualityWidget(
            imagePath: _imagePath, 
            onImageSelected: _onImageSelected,
            onSectionSelected: _onSectionSelected,
        ); // My widget for Image Quality Assessment
      case 'Image Modifier':
        return ImageModifierWidget(
            imagePath: _imagePath, 
            onImageSelected: _onImageSelected,
            onSectionSelected: _onSectionSelected,
        ); // My widget for Image Modifier
      case 'Batch Processing':
        return BatchProcessingWidget(
            imagePaths: _imagePaths,
            onImagesSelected: _onImagesSelected, 
            onSectionSelected: _onSectionSelected,
        ); // My widget for Batch Processing
      // Add other cases for different sections here
      default:
        return HomeWidget(
            imagePath: _imagePath, 
            onImageSelected: _onImageSelected,
            onSectionSelected: _onSectionSelected,
            notifications: _notifications,
            onRestore: _handleRestore,
            rightPanelKey: _rightPanelKey,
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
                : ValueListenableBuilder<List<NotificationCustom>>(
                    valueListenable: _notifications,
                    builder: (context, notifications, child) {
                      return AppBarWidget(
                        avatarUrl: widget.userAvatarUrl,
                        notifications: notifications,
                        onRestore: _handleRestore,
                        onClearNotifications: _handleClearNotifications,  
                      );
                    },
                  )),
      ),
      body: _getSectionWidget(),
      drawer: DrawerPage(onSectionSelected: _onSectionSelected),
    );
  }
}
