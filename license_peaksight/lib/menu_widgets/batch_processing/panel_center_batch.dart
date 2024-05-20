import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:license_peaksight/constants.dart';
import '../../quality_assessment/get_quality_scores.dart';

class PanelCenterBatchProcessing extends StatefulWidget {
  final List<String> imagePaths;
  final String selectedMetric;

  PanelCenterBatchProcessing({required this.imagePaths, required this.selectedMetric});

  @override
  _PanelCenterBatchProcessingState createState() => _PanelCenterBatchProcessingState();
}

class _PanelCenterBatchProcessingState extends State<PanelCenterBatchProcessing> {
  Map<String, double?> scoreMap = {};
  double progress = 0.0;
  Map<String, String> metricTiming = {};
  bool showTop10 = false;

  List<String> excellentImages = [];
  List<String> goodImages = [];
  List<String> fairImages = [];
  List<String> poorImages = [];
  List<String> badImages = [];
  List<String> outlierImages = [];

  String? selectedQualityFilter;
  bool showDropdown = false;
  bool showSaveButton = false;

  @override
  void didUpdateWidget(covariant PanelCenterBatchProcessing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedMetric != oldWidget.selectedMetric || widget.imagePaths != oldWidget.imagePaths) {
      // Reset progress and initiate a new calculation
      progress = 0.0;
      metricTiming.clear();
      calculateQualityScores();  // Recalculate scores if selected metric or images change
    }
  }

  void calculateQualityScores() async {
    if (widget.imagePaths.isNotEmpty && widget.selectedMetric.isNotEmpty) {
      for (String imagePath in widget.imagePaths) {
        final scores = await predictImageQuality(File(imagePath), {widget.selectedMetric});

        if (scores != null) {
          setState(() {
            // Assigning values directly based on whether they were requested
            if (widget.selectedMetric == 'Noise') {
              scoreMap[imagePath] = scores.noiseScore;
              metricTiming[imagePath] = "${scores.noiseTime}";
            }
            if (widget.selectedMetric == 'Contrast') {
              scoreMap[imagePath] = scores.contrastScore;
              metricTiming[imagePath] = "${scores.contrastTime}";
            }
            if (widget.selectedMetric == 'Brightness') {
              scoreMap[imagePath] = scores.brightnessScore;
              metricTiming[imagePath] = "${scores.brightnessTime}";
            }
            if (widget.selectedMetric == 'Sharpness') {
              scoreMap[imagePath] = scores.sharpnessScore;
              metricTiming[imagePath] = "${scores.sharpnessTime}";
            }
            if (widget.selectedMetric == 'Chromatic Quality') {
              scoreMap[imagePath] = scores.chromaticScore;
              metricTiming[imagePath] = "${scores.chromaticTime}";
            }
            if (widget.selectedMetric == 'BRISQUE') {
              scoreMap[imagePath] = scores.brisqueScore;
              metricTiming[imagePath] = "${scores.brisqueTime}";
            }
            if (widget.selectedMetric == 'NIQE') {
              scoreMap[imagePath] = scores.niqeScore;
              metricTiming[imagePath] = "${scores.niqeTime}";
            }
            if (widget.selectedMetric == 'ILNIQE') {
              scoreMap[imagePath] = scores.ilniqeScore;
              metricTiming[imagePath] = "${scores.ilniqeTime}";
            }
            if (widget.selectedMetric == 'VGG16') {
              scoreMap[imagePath] = scores.vgg16Score;
              metricTiming[imagePath] = "${scores.vgg16Time}";
            }
          });
        } else {
          // Show a dialog if the scores are null
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Warning"),
                content: Text("Caught an exception while fetching data for $imagePath. Please try again if necessary."),
                actions: <Widget>[
                  TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();  // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  String getQualityLevelMessage(double? score) {
    if (score == null) return "No score calculated";
    if (score > 5 || score < 1) return "Outlier score, image might be corrupted";
    if (score > 4 && score <= 5) return "Excellent";
    if (score > 3 && score <= 4) return "Good";
    if (score > 2 && score <= 3) return "Fair";
    if (score > 1.50 && score <= 2) return "Poor";
    return "Bad";
  }

  List<String> getTop10PercentImages() {
    List<MapEntry<String, double?>> sortedEntries = scoreMap.entries
        .where((entry) => entry.value != null)
        .toList()
        ..sort((a, b) => b.value!.compareTo(a.value!));
    int top10Count = (sortedEntries.length * 0.1).ceil();
    return sortedEntries.take(top10Count).map((entry) => entry.key).toList();
  }

  void classifyBatch() {
    excellentImages.clear();
    goodImages.clear();
    fairImages.clear();
    poorImages.clear();
    badImages.clear();
    outlierImages.clear();

    scoreMap.forEach((imagePath, score) {
      String qualityLabel = getQualityLevelMessage(score);
      switch (qualityLabel) {
        case 'Excellent':
          excellentImages.add(imagePath);
          break;
        case 'Good':
          goodImages.add(imagePath);
          break;
        case 'Fair':
          fairImages.add(imagePath);
          break;
        case 'Poor':
          poorImages.add(imagePath);
          break;
        case 'Bad':
          badImages.add(imagePath);
          break;
        case 'Outlier score, image might be corrupted':
          outlierImages.add(imagePath);
          break;
      }
    });
    setState(() {
      showDropdown = !showDropdown; // Toggle the dropdown visibility
      if (!showDropdown) {
        selectedQualityFilter = null; // Reset the filter when hiding the dropdown
      }
      showSaveButton = true; // Show the save button after classifying the batch
    });
  }

  Future<void> saveClassification() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      // User canceled the picker
      return;
    }

    final folders = {
      'Excellent': excellentImages,
      'Good': goodImages,
      'Fair': fairImages,
      'Poor': poorImages,
      'Bad': badImages,
      'Outlier': outlierImages,
    };

    for (var entry in folders.entries) {
      final folderPath = path.join(selectedDirectory, entry.key);
      await Directory(folderPath).create(recursive: true);
      for (var imagePath in entry.value) {
        final imageFileName = path.basename(imagePath);
        final newImagePath = path.join(folderPath, imageFileName);
        await File(imagePath).copy(newImagePath);
      }
    }

    // Show a dialog to indicate that the images have been saved
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Classification Saved"),
          content: Text("Images have been saved into folders based on their quality."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> displayImagePaths = showTop10 ? getTop10PercentImages() : widget.imagePaths;
    if (selectedQualityFilter != null) {
      displayImagePaths = filterImagesByQuality(selectedQualityFilter!);
    }
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top overview card
            buildOverviewCard(),
            // "Show top 10%" button and "Classify Batch" button
            Padding(
              padding: const EdgeInsets.all(Constants.kPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showTop10 = !showTop10;
                      });
                    },
                    child: Text(showTop10 ? 'Show All' : 'Show Best Picks', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.panelForeground,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: classifyBatch,
                    child: Text(showDropdown ? 'Hide Classification' : 'Classify Batch', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.panelForeground,
                    ),
                  ),
                ],
              ),
            ),
            // Quality Filter Dropdown (only visible after classifying batch)
            if (showDropdown)
              Padding(
                padding: const EdgeInsets.all(Constants.kPadding),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Constants.purpleLight,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: selectedQualityFilter,
                    hint: Text("Select Quality", style: TextStyle(color: Colors.white)),
                    dropdownColor: Constants.purpleLight,
                    iconEnabledColor: Colors.white,
                    underline: Container(height: 2, color: Colors.white),
                    items: [
                      DropdownMenuItem(
                        child: Text("All", style: TextStyle(color: Colors.white)),
                        value: null,
                      ),
                      DropdownMenuItem(
                        child: Text("Excellent", style: TextStyle(color: Colors.white)),
                        value: "Excellent",
                      ),
                      DropdownMenuItem(
                        child: Text("Good", style: TextStyle(color: Colors.white)),
                        value: "Good",
                      ),
                      DropdownMenuItem(
                        child: Text("Fair", style: TextStyle(color: Colors.white)),
                        value: "Fair",
                      ),
                      DropdownMenuItem(
                        child: Text("Poor", style: TextStyle(color: Colors.white)),
                        value: "Poor",
                      ),
                      DropdownMenuItem(
                        child: Text("Bad", style: TextStyle(color: Colors.white)),
                        value: "Bad",
                      ),
                      DropdownMenuItem(
                        child: Text("Outlier", style: TextStyle(color: Colors.white)),
                        value: "Outlier score, image might be corrupted",
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedQualityFilter = newValue;
                      });
                    },
                  ),
                ),
              ),
            // Save Classification Button (only visible after classifying batch)
            if (showSaveButton)
              Padding(
                padding: const EdgeInsets.all(Constants.kPadding),
                child: ElevatedButton(
                  onPressed: saveClassification,
                  child: Text('Save Classification', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.panelForeground,
                  ),
                ),
              ),
            // Dynamic list of metric scores with image thumbnails
            buildMetricsList(displayImagePaths),
          ],
        ),
      ),
    );
  }

  List<String> filterImagesByQuality(String quality) {
    switch (quality) {
      case 'Excellent':
        return excellentImages;
      case 'Good':
        return goodImages;
      case 'Fair':
        return fairImages;
      case 'Poor':
        return poorImages;
      case 'Bad':
        return badImages;
      case 'Outlier score, image might be corrupted':
        return outlierImages;
      default:
        return widget.imagePaths;
    }
  }

  Widget buildOverviewCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Constants.kPadding / 2, vertical: Constants.kPadding / 2),
      child: Card(
        color: Constants.purpleLight,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          padding: const EdgeInsets.all(Constants.kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Analysis Overview",
                style: TextStyle(
                  fontFamily: 'MOXABestine',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8), // Space between title and subtitle
              Text(
                "Image quality MOS scale scores",
                style: TextStyle(color: Color.fromARGB(156, 158, 158, 158)),
              ),
              SizedBox(height: 8), // Additional space before the table
              Container(
                decoration: BoxDecoration(
                  color: Colors.black54, // Dark background for the table
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      buildTableRow("Rating", "Quality Level", true),
                      buildTableRow("5", "Excellent", false),
                      buildTableRow("4", "Good", false),
                      buildTableRow("3", "Fair", false),
                      buildTableRow("2", "Poor", false),
                      buildTableRow("1", "Bad", false),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTableRow(String score, String label, bool isHeader) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(score, style: TextStyle(color: Colors.white, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
          Text(label, style: TextStyle(color: Colors.white, fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget buildMetricsList(List<String> displayImagePaths) {
    return Padding(
      padding: const EdgeInsets.all(Constants.kPadding),
      child: Card(
        color: Constants.purpleLight,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(Constants.kPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...displayImagePaths.map((imagePath) => buildMetricTile(imagePath, scoreMap[imagePath])).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMetricTile(String imagePath, double? score) {
    bool isCalculating = metricTiming[imagePath] == null;
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.file(
          File(imagePath),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
      subtitle: Text(
        score != null
            ? (metricTiming[imagePath] == null ? "Recalculating..." : "$score - ${getQualityLevelMessage(score)}")
            : "No score calculated",
        style: TextStyle(
          fontFamily: 'TellMeAJoke',
          fontSize: 17,
          color: Colors.grey[400],
        ),
      ),
      trailing: isCalculating
          ? SizedBox(
              width: 60, // Set a specific width for the SizedBox
              height: 20, // Set a specific height for the animation
              child: SpinKitThreeBounce(
                color: Colors.white,
                size: 20.0,
              ),
            )
          : Text(
              metricTiming[imagePath] ?? "Calculating...",
              style: TextStyle(color: Colors.grey[400]),
            ),
    );
  }
}
