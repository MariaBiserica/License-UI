import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:license_peaksight/authentication/animated_background/circle_painter.dart';

class PulsingBackground extends StatefulWidget {
  @override
  _PulsingBackgroundState createState() => _PulsingBackgroundState();
}

class _PulsingBackgroundState extends State<PulsingBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Offset> _positions1, _positions2, _positions3, _positions4, _positions5;

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
    _positions1 = generateRandomPositions(15);
    _positions2 = generateRandomPositions(10);
    _positions3 = generateRandomPositions(5);
    _positions4 = generateRandomPositions(5);
    _positions5 = generateRandomPositions(5);
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
                color: Color.fromARGB(255, 135, 95, 222).withOpacity(1 - _controller.value),
                positions: _positions1,
              ),
              child: CustomPaint(
                painter: CirclePainter(
                  context: context,
                  controllerValue: _controller.value,
                  color: Colors.cyan.withOpacity(1 - _controller.value),
                  positions: _positions2,
                ),
                child: CustomPaint(
                  painter: CirclePainter(
                    context: context,
                    controllerValue: _controller.value,
                    color: Color.fromARGB(179, 236, 22, 108).withOpacity(1 - _controller.value),
                    positions: _positions3,
                  ),
                  child: CustomPaint(
                    painter: CirclePainter(
                      context: context,
                      controllerValue: _controller.value,
                      color: Color.fromARGB(226, 247, 97, 4).withOpacity(1 - _controller.value),
                      positions: _positions4,
                    ),
                    child: CustomPaint(
                      painter: CirclePainter(
                        context: context,
                        controllerValue: _controller.value,
                        color: Color.fromARGB(204, 247, 4, 4).withOpacity(1 - _controller.value),
                        positions: _positions5,
                      ),
                    ),
                  ),
                ),
              )
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