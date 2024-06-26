import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
  final Map<String, Color> themeColors;

  PanelLeftImageModifier({
    required this.onMetricSelected,
    required this.onPointsChanged,
    required this.themeColors,
  });

  @override
  _PanelLeftImageModifierState createState() => _PanelLeftImageModifierState();
}

class _PanelLeftImageModifierState extends State<PanelLeftImageModifier> {
  final List<String> metrics = [
    'Sharpening',
    'Curves Adjustment',
    'Histogram Equalization',
    'Color Enhancement',
    'Color Space Conversion',
    'Inverse Color',
    'Morphological Transformation',
    'Gaussian Blur',
    'Median Blur',
    'Noise Reduction',
    'Edge Detection',
    'Image Rotation',
  ];

  final Map<String, String> metricDescriptions = {
    'Sharpening': 'For improving clarity and contrast.',
    'Curves Adjustment': 'For adjusting the tonal curves of the image. Modifies contrast and luminosity.',
    'Histogram Equalization': 'For highlighting details.',
    'Color Enhancement': 'For special effects and color adjustments.',
    'Color Space Conversion': 'For image transformation and adjustment.',
    'Inverse Color': 'For special effects and color adjustments.',
    'Morphological Transformation': 'For image transformation and adjustment.',
    'Gaussian Blur': 'For noise reduction.',
    'Median Blur': 'For noise reduction.',
    'Noise Reduction': 'For noise reduction.',
    'Edge Detection': 'For image transformation and adjustment.',
    'Image Rotation': 'For image transformation and adjustment.',
  };

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
    {'hueScalar': 0.7, 'saturationScalar': 1.5, 'valueScalar': 0.5},
    {'hueScalar': 0.7, 'saturationScalar': 1.5, 'valueScalar': 1.5},
    {'hueScalar': 1.3, 'saturationScalar': 1.5, 'valueScalar': 0.5},
    {'hueScalar': 1.3, 'saturationScalar': 1.5, 'valueScalar': 1.5},
    {'hueScalar': 1.1, 'saturationScalar': 1.2, 'valueScalar': 1.1},
    {'hueScalar': 1.2, 'saturationScalar': 1.5, 'valueScalar': 1.2},
    {'hueScalar': 1.5, 'saturationScalar': 2.0, 'valueScalar': 1.5},
  ];

  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();
    selectedMetric = metrics.first;
  }

  void applyPreset(Map<String, double> preset) {
    setState(() {
      hueScalar = preset['hueScalar']!;
      saturationScalar = preset['saturationScalar']!;
      valueScalar = preset['valueScalar']!;
    });
  }

  String getPreviewImagePath() {
    switch (selectedMetric) {
      case 'Color Space Conversion':
        return 'images/previews/Color Space Conversion_$selectedColorSpace.jpg';
      case 'Morphological Transformation':
        return 'images/previews/Morphological Transformation_$morphOperation.jpg';
      default:
        return 'images/previews/$selectedMetric.jpg';
    }
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
    } else if (selectedMetric == 'Median Blur') {
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
                  color: widget.themeColors['panelBackground'],
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(Constants.kPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Adjustment Tools",
                          style: TextStyle(
                            fontFamily: 'HeaderFont',
                            fontSize: 35,
                            color: widget.themeColors['textColor'],
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
                            fontSize: 16,
                            color: widget.themeColors['subtitleColor'],
                          ),
                        ),
                        Divider(color: widget.themeColors['dividerColor']),
                        if (selectedMetric != null)
                          Text(
                            metricDescriptions[selectedMetric!] ?? '',
                            style: TextStyle(
                              fontSize: 20,
                              color: widget.themeColors['textColor'],
                              shadows: <Shadow>[
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  offset: Offset(1, 2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                ),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    aspectRatio: 16 / 9,
                    viewportFraction: 0.8,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                        selectedMetric = metrics[index];
                      });
                    },
                  ),
                  items: metrics.map((metric) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            color: widget.themeColors['panelBackground'],
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                              image: AssetImage(getPreviewImagePath()),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.5),
                                BlendMode.dstATop,
                              ),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              metric,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'TellMeAJoke',
                                fontSize: 33.0,
                                color: widget.themeColors['textColor'],
                                fontWeight: FontWeight.bold,
                                shadows: <Shadow>[
                                  Shadow(
                                    color: Colors.black.withOpacity(1),
                                    offset: Offset(1, 3),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                  carouselController: _controller,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: widget.themeColors['textColor']),
                      onPressed: () {
                        _controller.previousPage();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_forward, color: widget.themeColors['textColor']),
                      onPressed: () {
                        _controller.nextPage();
                      },
                    ),
                  ],
                ),
                if (selectedMetric != null)
                  Padding(
                    padding: const EdgeInsets.all(Constants.kPadding),
                    child: Card(
                      color: widget.themeColors['panelBackground'],
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(Constants.kPadding),
                        child: Column(
                          children: [
                            if (selectedMetric == 'Image Rotation')
                              Column(
                                children: [
                                  Text(
                                    'Rotation Angle: ${rotationAngle.toInt()}°',
                                    style: TextStyle(color: widget.themeColors['textColor']),
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
                                    style: TextStyle(color: widget.themeColors['textColor']),
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
                              Column(
                                children: [
                                  DropdownButton<String>(
                                    value: selectedColorSpace,
                                    items: <String>['HSV', 'LAB', 'YCrCb'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value, style: TextStyle(color: widget.themeColors['textColor'])),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedColorSpace = newValue!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            if (selectedMetric == 'Morphological Transformation')
                              Column(
                                children: [
                                  DropdownButton<String>(
                                    value: morphOperation,
                                    items: <String>['dilation', 'erosion', 'opening', 'closing'].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value, style: TextStyle(color: widget.themeColors['textColor'])),
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
                                    style: TextStyle(color: widget.themeColors['textColor']),
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
                                    style: TextStyle(fontWeight: FontWeight.bold, color: widget.themeColors['detailsColor'], fontSize: 16),
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
                                          backgroundColor: isSelected ? widget.themeColors['selectedColor'] : widget.themeColors['panelForeground'],
                                        ),
                                        child: Text(
                                          'Hue: ${preset['hueScalar']}, Sat: ${preset['saturationScalar']}, Val: ${preset['valueScalar']}',
                                          style: TextStyle(color: widget.themeColors['textColor']),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Custom',
                                    style: TextStyle(fontWeight: FontWeight.bold, color: widget.themeColors['detailsColor'], fontSize: 16),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Hue Scalar: ${hueScalar.toStringAsFixed(2)}',
                                    style: TextStyle(color: widget.themeColors['textColor']),
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
                                    style: TextStyle(color: widget.themeColors['textColor']),
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
                                    style: TextStyle(color: widget.themeColors['textColor']),
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
                            if (selectedMetric == 'Sharpening' || selectedMetric == 'Median Blur')
                              Column(
                                children: [
                                  Text(
                                    'Kernel Size: $kernelSize',
                                    style: TextStyle(color: widget.themeColors['textColor']),
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
                            if (selectedMetric == 'Curves Adjustment')
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
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: startAnalysis,
                              child: Text('Start Analysis', style: TextStyle(color: widget.themeColors['textColor'])),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: widget.themeColors['panelForeground'],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
