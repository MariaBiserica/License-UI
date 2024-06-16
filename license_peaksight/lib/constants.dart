import 'package:flutter/material.dart';

class Constants {
  static const double kPadding = 10.0;
  static const double kPaddingHome = 20;
  static const double borderRadius = 20; 

  static const Color purpleLight = Color.fromARGB(255, 55, 2, 60); // Deep Purple
  static const Color purpleDark = Color.fromARGB(255, 33, 1, 36); // Very Dark Purple
  static const Color orangeLight = Color(0xfff8b250); // Light Orange
  static const Color redLight = Color(0xffff5182); // Light Red
  static const Color blueLight = Color(0xff0293ee); // Light Blue
  static const Color blue = Color.fromARGB(255, 113, 147, 247); // Soft Blue
  static const Color greenLight = Color(0xff13d38e); // Light Green

  // Theme definitions
  static const Map<String, Map<String, Color>> themes = {
    'Default': {
      'panelForeground': Color.fromARGB(255, 64, 95, 161), // Steel Blue
      'panelBackground': Color.fromARGB(255, 30, 30, 60), // Dark Slate Blue
      'appBackground': Color.fromARGB(255, 24, 24, 36), // Dark Midnight Blue
      'helpPanelBackground': Color.fromARGB(255, 179, 200, 219), // Light Steel Blue
      'gradientBegin': Color.fromARGB(255, 85, 124, 210), // Steel Blue
      'gradientEnd': Color.fromARGB(255, 173, 191, 210), // Light Slate Blue
      'notificationBadge': Color.fromARGB(255, 255, 99, 71), // Tomato
      'dividerColor': Color.fromARGB(136, 255, 255, 255), // Semi-Transparent White
      'textColor': Color.fromARGB(255, 210, 210, 210), // Light Grey
      'scoresColor': Color.fromARGB(255, 30, 30, 60), // Dark Slate Blue
      'subtitleColor': Color.fromARGB(156, 180, 180, 180), // Soft Grey
      'detailsColor': Color.fromARGB(255, 200, 200, 200), // Light Grey
      'selectedColor': Color.fromARGB(215, 100, 149, 237), // Cornflower Blue
    },
    'Pistachio': {
      'panelForeground': Color.fromARGB(255, 101, 155, 94), // Pistachio Green
      'panelBackground': Color.fromARGB(255, 85, 111, 68), // Olive Green
      'appBackground': Color.fromARGB(255, 53, 69, 42), // Dark Olive Green
      'helpPanelBackground': Color.fromARGB(255, 143, 189, 136), // Light Olive Green
      'gradientBegin': Color.fromARGB(255, 117, 150, 92), // Olive Drab
      'gradientEnd': Color.fromARGB(255, 153, 221, 200), // Pale Green
      'notificationBadge': Color.fromARGB(255, 153, 221, 200), // Pale Green
      'dividerColor': Color.fromARGB(202, 255, 255, 255), // Semi-Transparent White
      'textColor': Colors.white, // White
      'scoresColor': Color.fromARGB(255, 53, 69, 42), // Dark Olive Green
      'subtitleColor': Color.fromARGB(156, 209, 208, 208), // Soft Grey
      'detailsColor': Color.fromARGB(255, 224, 224, 224), // Light Grey
      'selectedColor': Color.fromARGB(255, 133, 209, 123), // Light Green
    },
    'Twilight Orchid': {
      'panelForeground': Color.fromARGB(255, 208, 57, 95), // Crimson
      'panelBackground': Color.fromARGB(255, 55, 2, 60), // Deep Purple
      'appBackground': Color.fromARGB(255, 33, 1, 36), // Very Dark Purple
      'helpPanelBackground': Color.fromARGB(255, 232, 225, 254), // Lavender
      'gradientBegin': Color.fromARGB(255, 208, 57, 95), // Crimson
      'gradientEnd': Color.fromARGB(255, 252, 222, 190), // Soft Peach
      'notificationBadge': Colors.pink, // Pink
      'dividerColor': Colors.white54, // Semi-Transparent White
      'textColor': Colors.white, // White
      'scoresColor': Color.fromARGB(255, 55, 2, 60), // Deep Purple
      'subtitleColor': Color.fromARGB(156, 158, 158, 158), // Soft Grey
      'detailsColor': Color.fromARGB(255, 224, 224, 224), // Light Grey
      'selectedColor': Color.fromARGB(215, 253, 141, 169), // Light Pink
    },
    'Crimson Dusk': {
      'panelForeground': Color.fromARGB(255, 200, 50, 50), // Crimson Red
      'panelBackground': Color.fromARGB(255, 60, 2, 2), // Dark Red
      'appBackground': Color.fromARGB(255, 36, 1, 1), // Very Dark Red
      'helpPanelBackground': Color.fromARGB(255, 255, 230, 230), // Light Rose
      'gradientBegin': Color.fromARGB(255, 200, 50, 50), // Crimson Red
      'gradientEnd': Color.fromARGB(255, 255, 200, 200), // Soft Pink
      'notificationBadge': Color.fromARGB(255, 255, 99, 71), // Tomato
      'dividerColor': Color.fromARGB(136, 255, 255, 255), // Semi-Transparent White
      'textColor': Color.fromARGB(255, 230, 230, 230), // Light Grey
      'scoresColor': Color.fromARGB(255, 60, 2, 2), // Dark Red
      'subtitleColor': Color.fromARGB(156, 200, 200, 200), // Soft Grey
      'detailsColor': Color.fromARGB(255, 210, 210, 210), // Light Grey
      'selectedColor': Color.fromARGB(215, 255, 160, 160), // Light Coral
    },
    'Silver Meadow': {
      'panelForeground': Color.fromARGB(255, 173, 198, 113), // Dandelion Yellow
      'panelBackground': Color.fromARGB(255, 105, 104, 104), // Silver
      'appBackground': Color.fromARGB(255, 163, 162, 162), // Light Grey
      'helpPanelBackground': Color.fromARGB(255, 240, 240, 240), // Light Snow
      'gradientBegin': Color.fromARGB(255, 109, 137, 43), // Golden Yellow
      'gradientEnd': Color.fromARGB(255, 215, 241, 153), // Lemon Chiffon
      'notificationBadge': Color.fromARGB(255, 255, 165, 0), // Orange
      'dividerColor': Color.fromARGB(135, 255, 254, 254), // Semi-Transparent Grey
      'textColor': Colors.white, // White
      'scoresColor': Color.fromARGB(255, 72, 71, 71), // Dark Silver
      'subtitleColor': Color.fromARGB(156, 232, 231, 231), // Soft Grey
      'detailsColor': Color.fromARGB(255, 231, 227, 227), // Light Grey
      'selectedColor': Color.fromARGB(215, 255, 228, 181), // Moccasin
    },
  };
}
