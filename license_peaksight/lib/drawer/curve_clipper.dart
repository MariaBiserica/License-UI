import 'package:flutter/material.dart';

class CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0); // Start from top-left corner
    path.lineTo(size.width - 50, 0); // Line to a point before top-right corner
    path.quadraticBezierTo(
      size.width, 0, // Control point for the curve
      size.width, 40, // End point for the curve
    );
    path.lineTo(size.width, size.height); // Line down to bottom-right corner
    path.lineTo(0, size.height); // Line to bottom-left corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
