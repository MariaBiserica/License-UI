import 'package:flutter/material.dart';
import 'package:license_peaksight/app_bar/notification_service.dart';
import 'package:license_peaksight/drawer/drawer_page.dart';
import 'package:license_peaksight/menu_widgets/home/panel_center_home.dart';
import 'package:license_peaksight/menu_widgets/home/panel_left_home.dart';
import 'package:license_peaksight/menu_widgets/home/panel_right_home.dart';
import 'package:license_peaksight/responsive_layout.dart';
import 'package:provider/provider.dart';
import 'package:license_peaksight/theme_provider.dart';

class HomeWidget extends StatefulWidget {
  final String imagePath;
  final Function(String) onImageSelected;
  final Function(String) onSectionSelected;
  final ValueNotifier<List<NotificationCustom>> notifications;
  final Function(NotificationCustom) onRestore;
  final GlobalKey<RightPanelHomeState> rightPanelKey; // Key to access the right panel state

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeColors = themeProvider.themeColors;

    return ResponsiveLayout(
      tiny: _buildScrollableColumnLayout(themeColors), // Single column for tiny layout
      phone: _buildScrollableColumnLayout(themeColors), // Single column for phone layout
      tablet: _buildTabletLayout(themeColors), // Custom layout for tablet
      largeTablet: _buildLargeTabletLayout(themeColors), // Side by side layout for large tablet
      computer: _buildComputerLayout(themeColors), // Side by side layout for computer
    );
  }

  Widget _buildScrollableColumnLayout(Map<String, Color> themeColors) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 400, child: LeftPanelHome(themeColors: themeColors)),
          SizedBox(height: 500, child: CenterPanelHome(themeColors: themeColors)),
          SizedBox(height: 500, child: RightPanelHome(
            notifications: widget.notifications,
            onRestore: widget.onRestore,
            key: widget.rightPanelKey,
            themeColors: themeColors,
          )),
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
            Expanded(child: SizedBox(height: 210, child: LeftPanelHome(themeColors: themeColors))),
            Expanded(flex: 2, child: SizedBox(height: 210, child: CenterPanelHome(themeColors: themeColors))),
          ],
        ),
        SizedBox(height: 330, child: RightPanelHome(
          notifications: widget.notifications,
          onRestore: widget.onRestore,
          key: widget.rightPanelKey,
          themeColors: themeColors,
        )),
      ],
    );
  }

  Widget _buildLargeTabletLayout(Map<String, Color> themeColors) {
    return Row(
      children: [
        Expanded(flex: 2, child: LeftPanelHome(themeColors: themeColors)),
        Expanded(flex: 2, child: CenterPanelHome(themeColors: themeColors)),
        Expanded(flex: 4, child: RightPanelHome(
          notifications: widget.notifications,
          onRestore: widget.onRestore,
          key: widget.rightPanelKey,
          themeColors: themeColors,
        )),
      ],
    );
  }

  Widget _buildComputerLayout(Map<String, Color> themeColors) {
    return Row(
      children: [
        Expanded(flex: 2, child: DrawerPage(onSectionSelected: widget.onSectionSelected)),
        Expanded(flex: 2, child: LeftPanelHome(themeColors: themeColors)),
        Expanded(flex: 2, child: CenterPanelHome(themeColors: themeColors)),
        Expanded(flex: 4, child: RightPanelHome(
          notifications: widget.notifications,
          onRestore: widget.onRestore,
          key: widget.rightPanelKey,
          themeColors: themeColors,
        )),
      ],
    );
  }
}
