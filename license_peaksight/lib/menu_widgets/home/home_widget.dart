import 'package:flutter/material.dart';
import 'package:license_peaksight/app_bar/notification_service.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/menu_widgets/home/panel_center_home.dart';
import 'package:license_peaksight/menu_widgets/home/panel_left_home.dart';
import 'package:license_peaksight/menu_widgets/home/panel_right_home.dart';
import 'package:license_peaksight/responsive_layout.dart';

class HomeWidget extends StatefulWidget {
  final String imagePath;
  final Function(String) onImageSelected;
  final Function(String) onSectionSelected; // callback for section changes
  final ValueNotifier<List<NotificationCustom>> notifications; // Notifications list
  final Function(NotificationCustom) onRestore; // Callback to restore task
  final GlobalKey<RightPanelHomeState> rightPanelKey; // Key to access RightPanelHome state

  HomeWidget({
    required this.imagePath,
    required this.onImageSelected,
    required this.onSectionSelected,
    required this.notifications,
    required this.onRestore,
    required this.rightPanelKey,
  });

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      tiny: _buildScrollableColumnLayout(), // Single column for tiny layout
      phone: _buildScrollableColumnLayout(), // Single column for phone layout
      tablet: _buildTabletLayout(), // Custom layout for tablet
      largeTablet: _buildLargeTabletLayout(), // Side by side layout for large tablet
      computer: _buildComputerLayout(), // Side by side layout for computer
    );
  }

  Widget _buildScrollableColumnLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 400, child: LeftPanelHome()),
          SizedBox(height: 500, child: CenterPanelHome()),
          SizedBox(height: 500, child: RightPanelHome(
            notifications: widget.notifications,
            onRestore: widget.onRestore,
            key: widget.rightPanelKey,
          )),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: SizedBox(height: 210, child: LeftPanelHome())),
            Expanded(flex: 2, child: SizedBox(height: 210, child: CenterPanelHome())),
          ],
        ),
        SizedBox(height: 330, child: RightPanelHome(
          notifications: widget.notifications,
          onRestore: widget.onRestore,
          key: widget.rightPanelKey,
        )),
      ],
    );
  }

  Widget _buildLargeTabletLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: LeftPanelHome()),
        Expanded(flex: 2, child: CenterPanelHome()),
        Expanded(flex: 4, child: RightPanelHome(
          notifications: widget.notifications,
          onRestore: widget.onRestore,
          key: widget.rightPanelKey,
        )),
      ],
    );
  }

  Widget _buildComputerLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: DrawerPage(onSectionSelected: widget.onSectionSelected)),
        Expanded(flex: 2, child: LeftPanelHome()),
        Expanded(flex: 2, child: CenterPanelHome()),
        Expanded(flex: 4, child: RightPanelHome(
          notifications: widget.notifications,
          onRestore: widget.onRestore,
          key: widget.rightPanelKey,
        )),
      ],
    );
  }
}
