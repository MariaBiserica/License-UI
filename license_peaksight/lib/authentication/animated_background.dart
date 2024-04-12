import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class PulsingBackground extends StatefulWidget {
  @override
  _PulsingBackgroundState createState() => _PulsingBackgroundState();
}

class _PulsingBackgroundState extends State<PulsingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> _positions;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // Duration for one full cycle
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _positions = generateRandomPositions(15);
  }

  List<Offset> generateRandomPositions(int count) {
    return List.generate(count, (index) {
      return Offset(
        Random().nextDouble() * MediaQuery.of(context).size.width,
        Random().nextDouble() * MediaQuery.of(context).size.height,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.deepPurple[900],
        width: double.infinity, // Ensures the Container fills the screen width
        height: double.infinity, // Ensures the Container fills the screen height
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: CirclePainter(
                context: context,
                controllerValue: _controller.value,
                positions: _positions,
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class CirclePainter extends CustomPainter {
  CirclePainter({
    required this.context,
    required this.controllerValue,
    required this.positions,
  });

  final BuildContext context;
  final double controllerValue;
  final List<Offset> positions;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color.fromARGB(255, 135, 95, 247).withOpacity(1 - controllerValue)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(100.0)); // Increase the sigma for a larger blur

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
