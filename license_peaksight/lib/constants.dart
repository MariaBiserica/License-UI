import 'package:flutter/material.dart';

 class Constants {
  static const double kPadding = 10.0;
  static const double kPaddingHome = 20;
  static const double borderRadius = 20; 

  static const Color purpleLight = Color.fromARGB(255, 55, 2, 60);
  static const Color purpleDark = Color.fromARGB(255, 33, 1, 36);
  static const Color orangeLight = Color(0xfff8b250);
  static const Color redLight = Color(0xffff5182);
  static const Color blueLight = Color(0xff0293ee);
  static const Color blue = Color.fromARGB(255, 113, 147, 247);
  static const Color greenLight = Color(0xff13d38e);
  static const Color beginGradient = Color.fromARGB(255, 208, 57, 95);
  static const Color endGradient = Color.fromARGB(255, 252, 222, 190);
  static const Color panelBackground = Color.fromARGB(255, 55, 2, 60);
  static const Color panelForeground = Color.fromARGB(255, 208, 57, 95);

  // Theme definitions
  static const Map<String, Map<String, Color>> themes = {
    'Purple': {
      'panelForeground': panelForeground,
      'panelBackground': panelBackground,
      'appBackground': purpleDark,
      'appBarBackground': panelBackground,
      'helpPanelBackground': Color.fromARGB(255, 232, 225, 254),
      'gradientBegin': beginGradient,
      'gradientEnd': endGradient,
      'notificationBadge': Colors.pink,
      'dividerColor':  Colors.white54,
      'textColor': Colors.white,
      'subtitleColor': Color.fromARGB(156, 158, 158, 158), 
      'detailsColor': Color.fromARGB(255, 224, 224, 224),
      'selectedColor': Color.fromARGB(215, 253, 141, 169),
    },
    'Blue': {
      'panelForeground': blue,
      'panelBackground': blueLight,
      'appBackground': blue,
      'appBarBackground': blueLight,
      'helpPanelBackground': Color.fromARGB(255, 225, 245, 254),
      'gradientBegin': blue,
      'gradientEnd': endGradient,
      'notificationBadge': Colors.blue,
      'dividerColor':  Colors.white54,
      'textColor': Colors.white,
      'subtitleColor': Color.fromARGB(156, 158, 158, 158), 
      'detailsColor': Color.fromARGB(255, 224, 224, 224),
      'selectedColor': Color.fromARGB(215, 253, 141, 169),
    },
    'Red': {
      'panelForeground': orangeLight,
      'panelBackground': redLight,
      'appBackground': redLight,
      'appBarBackground': redLight,
      'helpPanelBackground': Color.fromARGB(255, 254, 225, 225),
      'gradientBegin': redLight,
      'gradientEnd': endGradient,
      'notificationBadge': Colors.red,
      'dividerColor':  Colors.white54,
      'textColor': Colors.white,
      'subtitleColor': Color.fromARGB(156, 158, 158, 158), 
      'detailsColor': Color.fromARGB(255, 224, 224, 224),
      'selectedColor': Color.fromARGB(215, 253, 141, 169),
    },
    'Green': {
      'panelForeground': beginGradient,
      'panelBackground': greenLight,
      'appBackground': greenLight,
      'appBarBackground': greenLight,
      'helpPanelBackground': Color.fromARGB(255, 225, 254, 225),
      'gradientBegin': greenLight,
      'gradientEnd': endGradient,
      'notificationBadge': Colors.green,
      'dividerColor':  Colors.white54,
      'textColor': Colors.white,
      'subtitleColor': Color.fromARGB(156, 158, 158, 158), 
      'detailsColor': Color.fromARGB(255, 224, 224, 224),
      'selectedColor': Color.fromARGB(215, 253, 141, 169),
    },
  };
}
