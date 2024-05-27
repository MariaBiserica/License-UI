import 'package:flutter/material.dart';
import 'dart:math';

class HermiteCurvePainter extends CustomPainter {
  final List<Offset> points;
  HermiteCurvePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final double margin = 20.0; // Margin for labels
    final Offset origin = Offset(margin, size.height - margin); // Origin point with margins

    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    // Draw the axes
    canvas.drawLine(origin, Offset(size.width - margin, origin.dy), paint); // X axis
    canvas.drawLine(origin, Offset(origin.dx, margin), paint); // Y axis

    // Draw the grid and gradations
    final gridPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 0.5;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final double graphWidth = size.width - 2 * margin;
    final double graphHeight = size.height - 2 * margin;

    for (double i = 0; i <= graphWidth; i += graphWidth * 2 / 10) {
      canvas.drawLine(Offset(origin.dx + i, origin.dy), Offset(origin.dx + i, margin), gridPaint); // Vertical grid lines
      // Draw x-axis gradations
      final textSpan = TextSpan(
        text: (i / graphWidth * 255).round().toString(),
        style: TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(origin.dx + i - textPainter.width / 2, origin.dy + 2));
    }

    for (double i = 0; i <= graphHeight; i += graphHeight / 10) {
      canvas.drawLine(Offset(origin.dx, origin.dy - i), Offset(size.width - margin, origin.dy - i), gridPaint); // Horizontal grid lines
      // Draw y-axis gradations
      final textSpan = TextSpan(
        text: (i / graphHeight * 255).round().toString(),
        style: TextStyle(color: Colors.black, fontSize: 12),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(origin.dx - textPainter.width - 2, origin.dy - i - textPainter.height / 2));
    }

    // Draw the axes labels
    final textSpanX = TextSpan(
      text: 'Ox',
      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    );
    textPainter.text = textSpanX;
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - margin + 4, origin.dy + 12));

    final textSpanY = TextSpan(
      text: 'Oy',
      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    );
    textPainter.text = textSpanY;
    textPainter.layout();
    textPainter.paint(canvas, Offset(15, margin - 25));

    // Transform points to fit the coordinate system
    final transformedPoints = points
        .map((p) => Offset(
              origin.dx + p.dx / 255 * graphWidth,
              origin.dy - (255 - p.dy) / 255 * graphHeight, // Adjust Y transformation
            ))
        .toList();

    // Sort points by their x-coordinate
    final sortedPoints = List<Offset>.from(transformedPoints)..sort((a, b) => a.dx.compareTo(b.dx));

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
          if (x >= margin && x <= size.width - margin && y >= margin && y <= size.height - margin) {
            canvas.drawCircle(Offset(x, y), 1, curvePaint);
          }
        }
      }
    }

    // Draw the points and their coordinates
    final pointPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 6;

    for (final point in points) {
      final transformedPoint = Offset(
        origin.dx + point.dx / 255 * graphWidth,
        origin.dy - (255 - point.dy) / 255 * graphHeight,
      );
      canvas.drawCircle(transformedPoint, 4, pointPaint);

      final textSpan = TextSpan(
        text: '(${point.dx.round()}, ${255 - point.dy.round()})',
        style: TextStyle(color: Colors.black, fontSize: 8),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, Offset(transformedPoint.dx + 5, transformedPoint.dy - 12));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
