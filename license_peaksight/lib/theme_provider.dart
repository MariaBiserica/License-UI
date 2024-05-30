import 'package:flutter/material.dart';
import 'package:license_peaksight/constants.dart';

class ThemeProvider extends ChangeNotifier {
  String _selectedTheme = 'Default';

  String get selectedTheme => _selectedTheme;

  void changeTheme(String theme) {
    _selectedTheme = theme;
    notifyListeners();
  }

  Map<String, Color> get themeColors => Constants.themes[_selectedTheme]!;
}
