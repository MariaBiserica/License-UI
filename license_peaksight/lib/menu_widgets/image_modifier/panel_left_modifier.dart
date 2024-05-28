import 'dart:ui';

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
  final Function(String?, [Map<String, dynamic>?]) onMetricSelected;
  final Function(List<Offset>) onPointsChanged;

  PanelLeftImageModifier({required this.onMetricSelected, required this.onPointsChanged});

  @override
  _PanelLeftImageModifierState createState() => _PanelLeftImageModifierState();
}

class _PanelLeftImageModifierState extends State<PanelLeftImageModifier> {
  final List<String> metrics = [
    'Spline Interpolation',
    'Gaussian Blur',
    'Edge Detection',
    'Color Space Conversion',
    'Histogram Equalization',
    'Image Rotation',
    'Morphological Transformation',
    'Inverse Color',
    'Color Enhancement',
    'Sharpening'
  ];
  String? selectedMetric;
  double rotationAngle = 45.0;
  double blurAmount = 15.0;
  String selectedColorSpace = 'HSV';
  String morphOperation = 'dilation';
  int kernelSize = 3;
  double hueScalar = 1.0;
  double saturationScalar = 1.0;
  double valueScalar = 1.0;

  final List<Map<String, double>> colorEnhancementPresets = [
    {'hueScalar': 0.7, 'saturationScalar': 1.5, 'valueScalar': 0.5}, // Low saturation, low value
    {'hueScalar': 0.7, 'saturationScalar': 1.5, 'valueScalar': 1.5}, // Low saturation, high value
    {'hueScalar': 1.3, 'saturationScalar': 1.5, 'valueScalar': 0.5}, // High saturation, low value
    {'hueScalar': 1.3, 'saturationScalar': 1.5, 'valueScalar': 1.5}, // High saturation, high value
    {'hueScalar': 1.1, 'saturationScalar': 1.2, 'valueScalar': 1.1}, // Slight enhancement
    {'hueScalar': 1.2, 'saturationScalar': 1.5, 'valueScalar': 1.2}, // Medium enhancement
    {'hueScalar': 1.5, 'saturationScalar': 2.0, 'valueScalar': 1.5}, // Strong enhancement
  ];

  void toggleMetric(String metric) {
    setState(() {
      selectedMetric = (selectedMetric == metric) ? null : metric;
    });
  }

  void applyPreset(Map<String, double> preset) {
    setState(() {
      hueScalar = preset['hueScalar']!;
      saturationScalar = preset['saturationScalar']!;
      valueScalar = preset['valueScalar']!;
    });
  }

  void startAnalysis() {
    final Map<String, dynamic> options = {};
    if (selectedMetric == 'Image Rotation') {
      options['angle'] = rotationAngle;
    } else if (selectedMetric == 'Gaussian Blur') {
      options['blurAmount'] = blurAmount;
    } else if (selectedMetric == 'Color Space Conversion') {
      options['colorSpace'] = selectedColorSpace;
    } else if (selectedMetric == 'Morphological Transformation') {
      options['operation'] = morphOperation;
      options['kernelSize'] = kernelSize;
    } else if (selectedMetric == 'Color Enhancement') {
      options['hueScalar'] = hueScalar;
      options['saturationScalar'] = saturationScalar;
      options['valueScalar'] = valueScalar;
    } else if (selectedMetric == 'Sharpening') {
      options['kernelSize'] = kernelSize;
    }
    widget.onMetricSelected(selectedMetric, options);
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
                            fontFamily: 'HeaderFont', 
                            fontSize: 35, 
                            color: Color.fromARGB(215, 255, 255, 255),
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
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
                        if (selectedMetric == 'Image Rotation')
                          Column(
                            children: [
                              Text(
                                'Rotation Angle: ${rotationAngle.toInt()}°',
                                style: TextStyle(color: Colors.white),
                              ),
                              Slider(
                                value: rotationAngle,
                                min: 0,
                                max: 360,
                                divisions: 360,
                                label: rotationAngle.round().toString(),
                                onChanged: (double value) {
                                  setState(() {
                                    rotationAngle = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        if (selectedMetric == 'Gaussian Blur')
                          Column(
                            children: [
                              Text(
                                'Blur Amount: ${blurAmount.toInt()}',
                                style: TextStyle(color: Colors.white),
                              ),
                              Slider(
                                value: blurAmount,
                                min: 1,
                                max: 100,
                                divisions: 100,
                                label: blurAmount.round().toString(),
                                onChanged: (double value) {
                                  setState(() {
                                    blurAmount = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        if (selectedMetric == 'Color Space Conversion')
                          DropdownButton<String>(
                            value: selectedColorSpace,
                            items: <String>['HSV', 'LAB', 'YCrCb'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedColorSpace = newValue!;
                              });
                            },
                          ),
                        if (selectedMetric == 'Morphological Transformation')
                          Column(
                            children: [
                              DropdownButton<String>(
                                value: morphOperation,
                                items: <String>['dilation', 'erosion', 'opening', 'closing'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: TextStyle(color: Colors.white)),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    morphOperation = newValue!;
                                  });
                                },
                              ),
                              Text(
                                'Kernel Size: $kernelSize',
                                style: TextStyle(color: Colors.white),
                              ),
                              Slider(
                                value: kernelSize.toDouble(),
                                min: 1,
                                max: 20,
                                divisions: 19,
                                label: kernelSize.toString(),
                                onChanged: (double value) {
                                  setState(() {
                                    kernelSize = value.toInt();
                                  });
                                },
                              ),
                            ],
                          ),
                        if (selectedMetric == 'Color Enhancement')
                          Column(
                            children: [
                              Text(
                                'Presets',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(172, 255, 255, 255), fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: colorEnhancementPresets.map((preset) {
                                  final bool isSelected = hueScalar == preset['hueScalar'] &&
                                      saturationScalar == preset['saturationScalar'] &&
                                      valueScalar == preset['valueScalar'];
                                  return ElevatedButton(
                                    onPressed: () => applyPreset(preset),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected ? Color.fromARGB(215, 253, 141, 169) : Constants.panelForeground,
                                    ),
                                    child: Text(
                                      'Hue: ${preset['hueScalar']}, Sat: ${preset['saturationScalar']}, Val: ${preset['valueScalar']}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Custom',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(172, 255, 255, 255), fontSize: 16),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Hue Scalar: ${hueScalar.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.white),
                              ),
                              Slider(
                                value: hueScalar,
                                min: 0.0,
                                max: 2.0,
                                divisions: 20,
                                label: hueScalar.toStringAsFixed(2),
                                onChanged: (double value) {
                                  setState(() {
                                    hueScalar = value;
                                  });
                                },
                              ),
                              Text(
                                'Saturation Scalar: ${saturationScalar.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.white),
                              ),
                              Slider(
                                value: saturationScalar,
                                min: 0.0,
                                max: 2.0,
                                divisions: 20,
                                label: saturationScalar.toStringAsFixed(2),
                                onChanged: (double value) {
                                  setState(() {
                                    saturationScalar = value;
                                  });
                                },
                              ),
                              Text(
                                'Value Scalar: ${valueScalar.toStringAsFixed(2)}',
                                style: TextStyle(color: Colors.white),
                              ),
                              Slider(
                                value: valueScalar,
                                min: 0.0,
                                max: 2.0,
                                divisions: 20,
                                label: valueScalar.toStringAsFixed(2),
                                onChanged: (double value) {
                                  setState(() {
                                    valueScalar = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        if (selectedMetric == 'Sharpening')
                          Column(
                            children: [
                              Text(
                                'Kernel Size: $kernelSize',
                                style: TextStyle(color: Colors.white),
                              ),
                              Slider(
                                value: kernelSize.toDouble(),
                                min: 1,
                                max: 21,
                                divisions: 10,
                                label: kernelSize.toString(),
                                onChanged: (double value) {
                                  setState(() {
                                    kernelSize = value.toInt();
                                  });
                                },
                              ),
                            ],
                          ),
                        SizedBox(height: Constants.kPadding),
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
