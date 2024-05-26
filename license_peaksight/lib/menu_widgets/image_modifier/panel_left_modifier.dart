import 'package:flutter/material.dart';
import 'package:license_peaksight/constants.dart';

class PanelLeftImageModifier extends StatefulWidget {
  final Function(String?) onMetricSelected;

  PanelLeftImageModifier({required this.onMetricSelected});

  @override
  _PanelLeftImageModifierState createState() => _PanelLeftImageModifierState();
}

class _PanelLeftImageModifierState extends State<PanelLeftImageModifier> {
  final List<String> metrics = [
    'Spline Interpolation', 'Other'
  ];
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(Constants.kPadding),
          child: Card(
            color: Constants.purpleLight,
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(Constants.kPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Adjsutments Presets",
                    style: TextStyle(
                      fontFamily: 'MOXABestine',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                  Text(
                    "Select what kind of adjustments you want to make to the image.",
                    style: TextStyle(
                      fontSize: 14, 
                      color: Color.fromARGB(156, 158, 158, 158)
                    ),
                  ),
                  Divider(color: Colors.white30),
                  ...metrics.map((metric) => RadioListTile<String>(
                    title: Text(
                      metric, 
                      style: TextStyle(
                        fontFamily: 'TellMeAJoke',
                        fontSize: 21, 
                        color: Colors.white
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
        ),
      ),
    );
  }
}
