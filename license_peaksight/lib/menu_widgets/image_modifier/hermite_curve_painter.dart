import 'package:flutter/material.dart';
import 'dart:math';

class HermiteCurvePainter extends CustomPainter {
  final List<Offset> points;
  HermiteCurvePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    // Draw the axes
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, size.height), paint);

    // Draw the grid and gradations
    final gridPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 0.5;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (double i = 0; i <= size.width; i += size.width / 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
      // Draw x-axis gradations
      final textSpan = TextSpan(
        text: (i / size.width * 255).round().toString(),
        style: TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(i - textPainter.width / 2, size.height + 2));
    }

    for (double i = 0; i <= size.height; i += size.height / 10) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
      // Draw y-axis gradations
      final textSpan = TextSpan(
        text: (255 - i / size.height * 255).round().toString(),
        style: TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width - 2, i - textPainter.height / 2));
    }

    // Draw the axes labels
    final textSpanX = TextSpan(
      text: 'Ox',
      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    );
    textPainter.text = textSpanX;
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 20, size.height - 20));

    final textSpanY = TextSpan(
      text: 'Oy',
      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    );
    textPainter.text = textSpanY;
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, 10));

    // Sort points by their x-coordinate
    final sortedPoints = List<Offset>.from(points)..sort((a, b) => a.dx.compareTo(b.dx));

    // Draw the Hermite curve
    if (sortedPoints.length >= 2) {
      final curvePaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2;

      for (int i = 0; i < sortedPoints.length - 1; i++) {
        final p0 = sortedPoints[i];
        final p1 = sortedPoints[i + 1];
        final pMinus1 = i == 0 ? Offset(2 * p0.dx - p1.dx, 2 * p0.dy - p1.dy) : sortedPoints[i - 1];
        final p2 = i + 2 < sortedPoints.length ? sortedPoints[i + 2] : Offset(2 * p1.dx - p0.dx, 2 * p1.dy - p0.dy);

        final m0 = Offset((p1.dx - pMinus1.dx) / 2, (p1.dy - pMinus1.dy) / 2);
        final m1 = Offset((p2.dx - p0.dx) / 2, (p2.dy - p0.dy) / 2);

        for (double t = 0; t <= 1; t += 0.01) {
          final h1 = 2 * pow(t, 3) - 3 * pow(t, 2) + 1;
          final h2 = -2 * pow(t, 3) + 3 * pow(t, 2);
          final h3 = pow(t, 3) - 2 * pow(t, 2) + t;
          final h4 = pow(t, 3) - pow(t, 2);

          final x = h1 * p0.dx + h2 * p1.dx + h3 * m0.dx + h4 * m1.dx;
          final y = h1 * p0.dy + h2 * p1.dy + h3 * m0.dy + h4 * m1.dy;

          // Ensure points are within canvas bounds
          if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
            canvas.drawCircle(Offset(x, y), 1, curvePaint);
          }
        }
      }
    }

    // Draw the points and their coordinates
    final pointPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 6;

    for (final point in sortedPoints) {
      canvas.drawCircle(point, 4, pointPaint);

      final textSpan = TextSpan(
        text: '(${point.dx.round()}, ${255 - point.dy.round()})',
        style: TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(point.dx + 5, point.dy - 12));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
