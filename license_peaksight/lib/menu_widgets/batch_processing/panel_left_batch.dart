import 'package:flutter/material.dart';
import 'package:license_peaksight/constants.dart';

class PanelLeftBatchProcessing extends StatefulWidget {
  final Function(String) onMetricSelected;

  PanelLeftBatchProcessing({required this.onMetricSelected});

  @override
  _PanelLeftBatchProcessingState createState() => _PanelLeftBatchProcessingState();
}

class _PanelLeftBatchProcessingState extends State<PanelLeftBatchProcessing> {
  String selectedMetric = 'Noise';
  String? selectedOverallQualityMetric;
  bool isOverallQualitySelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Constants.kPadding),
      child: Card(
        color: Constants.purpleLight,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(Constants.kPadding),
              child: Text(
                "Control Center",
                style: TextStyle(
                  fontFamily: 'MOXABestine',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Constants.kPadding),
              child: Text(
                "Select which metric to assess:",
                style: TextStyle(
                  fontFamily: 'Voguella',
                  fontSize: 14,
                  color: Color.fromARGB(156, 158, 158, 158),
                ),
              ),
            ),
            DropdownButton<String>(
              value: selectedMetric,
              icon: Icon(Icons.arrow_downward, color: Colors.white),
              dropdownColor: Constants.purpleLight,
              underline: Container(height: 2, color: Colors.white),
              onChanged: (String? newValue) {
                setState(() {
                  selectedMetric = newValue!;
                  isOverallQualitySelected = newValue == 'Overall Quality Score';
                  selectedOverallQualityMetric = null; // Reset secondary selection
                  widget.onMetricSelected(selectedMetric);
                });
              },
              items: <String>[
                'Noise', 'Contrast', 'Brightness', 'Sharpness', 'Chromatic Quality', 'Overall Quality Score'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
            SizedBox(height: 15),
            if (isOverallQualitySelected) ...[
              SizedBox(height: 10),
              Text(
                "Select detailed quality metric:",
                style: TextStyle(
                  fontFamily: 'Voguella',
                  fontSize: 14, 
                  color: Colors.white
                ),
              ),
              SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedOverallQualityMetric,
                icon: Icon(Icons.arrow_downward, color: Colors.white),
                dropdownColor: Constants.purpleLight,
                underline: Container(height: 2, color: Colors.white),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOverallQualityMetric = newValue!;
                    widget.onMetricSelected(selectedOverallQualityMetric!);
                  });
                },
                items: <String>['BRISQUE', 'NIQE', 'ILNIQE', 'VGG16']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
              SizedBox(height: 15),
            ]
          ],
        ),
      ),
    );
  }
}
