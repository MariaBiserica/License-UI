import 'package:flutter/material.dart';
import 'package:license_peaksight/menu_widgets/image_modifier/hermite_curve_painter.dart';
import 'package:provider/provider.dart';
import 'package:license_peaksight/constants.dart';

class PointProvider with ChangeNotifier {
  List<Offset> _points = [Offset(0, 255), Offset(255, 0)];

  List<Offset> get points => _points;

  void addPoint(Offset point) {
    if (_points.length < 5) {
      _points.insert(_points.length - 1, point);
      notifyListeners();
    }
  }

  void clearPoints() {
    _points = [Offset(0, 255), Offset(255, 0)];
    notifyListeners();
  }
}

class PanelLeftImageModifier extends StatefulWidget {
  final Function(String?) onMetricSelected;
  final Function(List<Offset>) onPointsChanged;

  PanelLeftImageModifier({required this.onMetricSelected, required this.onPointsChanged});

  @override
  _PanelLeftImageModifierState createState() => _PanelLeftImageModifierState();
}

class _PanelLeftImageModifierState extends State<PanelLeftImageModifier> {
  final List<String> metrics = ['Spline Interpolation', 'Other'];
  String? selectedMetric;

  void toggleMetric(String metric) {
    setState(() {
      selectedMetric = (selectedMetric == metric) ? null : metric;
    });
  }

  void startAnalysis() {
    widget.onMetricSelected(selectedMetric);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PointProvider(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(Constants.kPadding),
            child: Column(
              children: [
                Card(
                  color: Constants.purpleLight,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(Constants.kPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Adjustments Presets",
                          style: TextStyle(
                            fontFamily: 'MOXABestine',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Select what kind of adjustments you want to make to the image.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(156, 158, 158, 158),
                          ),
                        ),
                        Divider(color: Colors.white30),
                        ...metrics.map((metric) => RadioListTile<String>(
                              title: Text(
                                metric,
                                style: TextStyle(
                                  fontFamily: 'TellMeAJoke',
                                  fontSize: 21,
                                  color: Colors.white,
                                ),
                              ),
                              value: metric,
                              groupValue: selectedMetric,
                              onChanged: (value) => toggleMetric(value!),
                              activeColor: Constants.endGradient,
                            )),
                        ElevatedButton(
                          onPressed: startAnalysis,
                          child: Text('Start Analysis', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.panelForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (selectedMetric == 'Spline Interpolation')
                  Consumer<PointProvider>(
                    builder: (context, pointProvider, child) {
                      // Schedule the callback after the build process is complete
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        widget.onPointsChanged(pointProvider.points);
                      });
                      return Padding(
                        padding: const EdgeInsets.only(top: Constants.kPadding),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(Constants.kPadding),
                            child: Column(
                              children: [
                                HermiteCurveInterpolation(),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () => pointProvider.clearPoints(),
                                  child: Text('Clear Points'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HermiteCurveInterpolation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PointProvider>(
      builder: (context, pointProvider, child) {
        return Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              padding: EdgeInsets.all(Constants.kPadding),
              color: Colors.white,
              child: GestureDetector(
                onTapUp: (details) {
                  final RenderBox renderBox = context.findRenderObject() as RenderBox;
                  final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
                  pointProvider.addPoint(localPosition);
                },
                child: CustomPaint(
                  painter: HermiteCurvePainter(pointProvider.points),
                  child: Container(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
