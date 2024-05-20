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

  void startAnalysis() {
    if (isOverallQualitySelected && selectedOverallQualityMetric != null) {
      print("Selected overall quality metric: $selectedOverallQualityMetric");
      widget.onMetricSelected(selectedOverallQualityMetric!);
    } else {
      print("Selected metric: $selectedMetric");
      widget.onMetricSelected(selectedMetric);
    }
  }

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
                  selectedOverallQualityMetric = null; // Reset secondary selection if metric changes
                });
              },
              items: getDropdownMenuItems(),
            ),
            SizedBox(height: 10),
            if (isOverallQualitySelected) ...[
              Text(
                "Select detailed quality metric:",
                style: TextStyle(
                  fontFamily: 'Voguella',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 5),
              DropdownButton<String>(
                value: selectedOverallQualityMetric,
                icon: Icon(Icons.arrow_downward, color: Colors.white),
                dropdownColor: Constants.purpleLight,
                underline: Container(height: 2, color: Colors.white),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedOverallQualityMetric = newValue!;
                  });
                },
                items: getQualityDropdownItems(),
              ),
              SizedBox(height: 10),
            ],
            ElevatedButton(
              onPressed: startAnalysis,
              child: Text('Start Analysis', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.panelForeground,
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> getDropdownMenuItems() {
    Map<String, IconData> icons = {
      'Noise': Icons.waves,
      'Contrast': Icons.tonality,
      'Brightness': Icons.brightness_6,
      'Sharpness': Icons.details,
      'Chromatic Quality': Icons.palette,
      'Overall Quality Score': Icons.score,
    };

    return icons.keys.map((String key) {
      return DropdownMenuItem<String>(
        value: key,
        child: Row(
          children: [
            Icon(icons[key], color: Colors.white),
            SizedBox(width: 8),
            Text(key, style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> getQualityDropdownItems() {
    Map<String, IconData> icons = {
      'BRISQUE': Icons.filter_1,
      'NIQE': Icons.filter_2,
      'ILNIQE': Icons.filter_3,
      'VGG16': Icons.filter_4,
    };

    return icons.keys.map((String key) {
      return DropdownMenuItem<String>(
        value: key,
        child: Row(
          children: [
            Icon(icons[key], color: Colors.white),
            SizedBox(width: 8),
            Text(key, style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }).toList();
  }
}
