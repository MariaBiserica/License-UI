import 'package:flutter/material.dart';
import 'package:license_peaksight/constants.dart';

class PanelLeftPage extends StatefulWidget {
  final Function(Set<String>) onMetricsSelected;

  PanelLeftPage({required this.onMetricsSelected});

  @override
  _PanelLeftPageState createState() => _PanelLeftPageState();
}

class _PanelLeftPageState extends State<PanelLeftPage> {
  final List<String> metrics = [
    'Noise', 'Contrast', 'Brightness', 'Sharpness', 'Chromatic Quality'
  ];
  final List<String> qualityMetrics = ['BRISQUE', 'NIQE', 'ILNIQE', 'VGG16'];
  final Map<String, bool> selectedMetrics = {};
  bool showQualityOptions = false; // Flag to show/hide quality metrics

  @override
  void initState() {
    super.initState();
    metrics.forEach((metric) {
      selectedMetrics[metric] = false;
    });
    qualityMetrics.forEach((metric) {
      selectedMetrics[metric] = false;
    });
  }

  void toggleMetric(String metric) {
    setState(() {
      selectedMetrics[metric] = !selectedMetrics[metric]!;
    });
  }

  void toggleQualityOptions() {
    setState(() {
      showQualityOptions = !showQualityOptions;
    });
  }

  void startAnalysis() {
    Set<String> selected = selectedMetrics.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toSet();
    widget.onMetricsSelected(selected);
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
                    "Control Center",
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
                    "Select which metrics you want to assess!",
                    style: TextStyle(
                      fontSize: 14, 
                      color: Color.fromARGB(156, 158, 158, 158)
                    ),
                  ),
                  Divider(color: Colors.white30),
                  ...metrics.map((metric) => CheckboxListTile(
                    title: Text(
                      metric, 
                      style: TextStyle(
                        fontFamily: 'TellMeAJoke',
                        fontSize: 21, 
                        color: Colors.white
                      ),
                    ),
                    value: selectedMetrics[metric],
                    onChanged: (_) => toggleMetric(metric),
                    activeColor: Constants.endGradient,
                    checkColor: Colors.white,
                  )),
                  ListTile(
                    title: Text(
                      'Overall Quality Score',
                      style: TextStyle(
                        fontFamily: 'TellMeAJoke',
                        fontSize: 21, 
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    trailing: Icon(
                      showQualityOptions ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: Colors.white
                    ),
                    onTap: toggleQualityOptions,
                  ),
                  if (showQualityOptions) Wrap(
                    children: qualityMetrics.map((metric) => CheckboxListTile(
                      title: Text(
                        metric,
                        style: TextStyle(
                          fontFamily: 'TellMeAJoke',
                          fontSize: 21, 
                          color: Colors.white
                        ),
                      ),
                      value: selectedMetrics[metric],
                      onChanged: (_) => toggleMetric(metric),
                      activeColor: Constants.endGradient,
                      checkColor: Colors.white,
                    )).toList(),
                  ),
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
