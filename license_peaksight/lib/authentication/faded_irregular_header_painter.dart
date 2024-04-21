import 'package:flutter/material.dart';

class FadedIrregularHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    // Updated the gradient to include bright orange and extend the fade to transparent
    paint.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Colors.deepPurple[800]!.withOpacity(0.7),
        Color.fromARGB(255, 239, 0, 100).withOpacity(0.7),
        Colors.transparent
      ],
      stops: [0.1, 0.7, 1.0], // Adjust stops to control the transition points
    ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    var path = Path();
    // Adjust the bezier curve points to create a more dramatic "flow" effect
    path.moveTo(0, size.height * 0.3); // Start slightly above bottom left
    path.quadraticBezierTo(
      size.width * 0.7, size.height *  1.2, // Control point lower to create a dip
      size.width * 0.7, size.height * 0.6, // Mid point at center of canvas at half height
    );
    path.quadraticBezierTo(
      size.width * 0.7, 0, // Control point above canvas to create a rise
      size.width, size.height * 0.8, // Ending point back near bottom right
    );
    path.lineTo(size.width, 0); // Connect to the top right corner
    path.lineTo(0, 0); // Connect back to the top left corner
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
