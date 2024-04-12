import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  CirclePainter({
    required this.context,
    required this.controllerValue,
    required this.color,
    required this.positions,
  });

  final BuildContext context;
  final double controllerValue;
  final Color color;
  final List<Offset> positions;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(110.0)); // Increase the sigma for a larger blur

    // The radius is multiplied by a larger number to increase the size
    double radius = controllerValue * 20.0 + 50.0; // Base radius + animated growth
    for (var position in positions) {
      canvas.drawCircle(position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => true;

  double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }
}