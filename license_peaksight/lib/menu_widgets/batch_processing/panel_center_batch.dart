import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';
import 'package:license_peaksight/constants.dart';
import '../../server_requests/get_quality_scores.dart';
import 'dart:ui' as ui;

class PanelCenterBatchProcessing extends StatefulWidget {
  final List<String> imagePaths;
  final String selectedMetric;
  final Function(List<double>) onScoresCalculated;
  final Map<String, Color> themeColors;

  PanelCenterBatchProcessing({
    required this.imagePaths,
    required this.selectedMetric,
    required this.onScoresCalculated,
    required this.themeColors,
  });

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
      progress = 0.0;
      metricTiming.clear();
      calculateQualityScores();
    }
  }

  void calculateQualityScores() async {
    List<double> scores = [];

    if (widget.imagePaths.isNotEmpty && widget.selectedMetric.isNotEmpty) {
      for (String imagePath in widget.imagePaths) {
        final scoresResult = await predictImageQuality(File(imagePath), {widget.selectedMetric});

        if (scoresResult != null) {
          setState(() {
            double? score;
            if (widget.selectedMetric == 'Noise') {
              score = scoresResult.noiseScore;
              metricTiming[imagePath] = "${scoresResult.noiseTime}";
            }
            if (widget.selectedMetric == 'Contrast') {
              score = scoresResult.contrastScore;
              metricTiming[imagePath] = "${scoresResult.contrastTime}";
            }
            if (widget.selectedMetric == 'Brightness') {
              score = scoresResult.brightnessScore;
              metricTiming[imagePath] = "${scoresResult.brightnessTime}";
            }
            if (widget.selectedMetric == 'Sharpness') {
              score = scoresResult.sharpnessScore;
              metricTiming[imagePath] = "${scoresResult.sharpnessTime}";
            }
            if (widget.selectedMetric == 'Chromatic Quality') {
              score = scoresResult.chromaticScore;
              metricTiming[imagePath] = "${scoresResult.chromaticTime}";
            }
            if (widget.selectedMetric == 'BRISQUE') {
              score = scoresResult.brisqueScore;
              metricTiming[imagePath] = "${scoresResult.brisqueTime}";
            }
            if (widget.selectedMetric == 'NIQE') {
              score = scoresResult.niqeScore;
              metricTiming[imagePath] = "${scoresResult.niqeTime}";
            }
            if (widget.selectedMetric == 'ILNIQE') {
              score = scoresResult.ilniqeScore;
              metricTiming[imagePath] = "${scoresResult.ilniqeTime}";
            }
            if (widget.selectedMetric == 'VGG16') {
              score = scoresResult.vgg16Score;
              metricTiming[imagePath] = "${scoresResult.vgg16Time}";
            }

            if (score != null) {
              scoreMap[imagePath] = score;
              scores.add(score);
            }
          });
        } else {
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
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }

      widget.onScoresCalculated(scores);
    }
  }

  String getQualityLevelMessage(double? score) {
    if (score == null) return "No score calculated";
    if (score > 5 || score < 1) return "Outlier";
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
        case 'Outlier':
          outlierImages.add(imagePath);
          break;
      }
    });
    setState(() {
      showDropdown = !showDropdown;
      if (!showDropdown) {
        selectedQualityFilter = null;
        showSaveButton = false;
      } else {
        showSaveButton = true;
      }
    });
  }

  Future<void> saveClassification() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
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
                Navigator.of(context).pop();
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
            buildOverviewCard(),
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
                    child: Text(showTop10 ? 'Show All' : 'Show Best Picks', style: TextStyle(color: widget.themeColors['textColor'])),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColors['panelForeground'],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: classifyBatch,
                    child: Text(showDropdown ? 'Hide Classification' : 'Classify Batch', style: TextStyle(color: widget.themeColors['textColor'])),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.themeColors['panelForeground'],
                    ),
                  ),
                ],
              ),
            ),
            if (showDropdown)
              Padding(
                padding: const EdgeInsets.all(Constants.kPadding),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.themeColors['panelBackground'],
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
                    hint: Text("Select Quality", style: TextStyle(color: widget.themeColors['textColor'])),
                    dropdownColor: widget.themeColors['panelBackground'],
                    iconEnabledColor: widget.themeColors['textColor'],
                    underline: Container(height: 2, color: widget.themeColors['textColor']),
                    items: [
                      DropdownMenuItem(
                        child: Text("All", style: TextStyle(color: widget.themeColors['textColor'])),
                        value: null,
                      ),
                      DropdownMenuItem(
                        child: Text("Excellent", style: TextStyle(color: widget.themeColors['textColor'])),
                        value: "Excellent",
                      ),
                      DropdownMenuItem(
                        child: Text("Good", style: TextStyle(color: widget.themeColors['textColor'])),
                        value: "Good",
                      ),
                      DropdownMenuItem(
                        child: Text("Fair", style: TextStyle(color: widget.themeColors['textColor'])),
                        value: "Fair",
                      ),
                      DropdownMenuItem(
                        child: Text("Poor", style: TextStyle(color: widget.themeColors['textColor'])),
                        value: "Poor",
                      ),
                      DropdownMenuItem(
                        child: Text("Bad", style: TextStyle(color: widget.themeColors['textColor'])),
                        value: "Bad",
                      ),
                      DropdownMenuItem(
                        child: Text("Outlier", style: TextStyle(color: widget.themeColors['textColor'])),
                        value: "Outlier",
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
            if (showSaveButton)
              Padding(
                padding: const EdgeInsets.all(Constants.kPadding),
                child: ElevatedButton(
                  onPressed: saveClassification,
                  child: Text('Save Classification', style: TextStyle(color: widget.themeColors['textColor'])),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColors['panelForeground'],
                  ),
                ),
              ),
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
      case 'Outlier':
        return outlierImages;
      default:
        return widget.imagePaths;
    }
  }

  Widget buildOverviewCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Constants.kPadding / 2, vertical: Constants.kPadding / 2),
      child: Card(
        color: widget.themeColors['panelBackground'],
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
              SizedBox(height: 8),
              Text(
                "Image quality MOS scale scores",
                style: TextStyle(color: Color.fromARGB(156, 158, 158, 158)),
              ),
              SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
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
          Text(score, style: TextStyle(color: widget.themeColors['textColor'], fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
          Text(label, style: TextStyle(color: widget.themeColors['textColor'], fontWeight: isHeader ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget buildMetricsList(List<String> displayImagePaths) {
    return Padding(
      padding: const EdgeInsets.all(Constants.kPadding),
      child: Card(
        color: widget.themeColors['panelBackground'],
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
      leading: GestureDetector(
        onTap: () => viewImage(context, imagePath, "center_panel"),
        child: Hero(
          tag: "center_panel_$imagePath",
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.file(
              File(imagePath),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      title: Text(
        path.basename(imagePath),
        style: TextStyle(
          fontSize: 15,
          color: widget.themeColors['textColor'],
        ),
      ),
      subtitle: Text(
        score != null
            ? (metricTiming[imagePath] == null ? "Recalculating..." : "$score - ${getQualityLevelMessage(score)}")
            : "No score calculated",
        style: TextStyle(
          fontFamily: 'TellMeAJoke',
          fontSize: 17,
          color: widget.themeColors['subtitleColor'],
        ),
      ),
      trailing: isCalculating
          ? SizedBox(
              width: 60,
              height: 20,
              child: SpinKitThreeBounce(
                color: widget.themeColors['textColor'],
                size: 20.0,
              ),
            )
          : Text(
              metricTiming[imagePath] ?? "Calculating...",
              style: TextStyle(color: widget.themeColors['subtitleColor']),
            ),
    );
  }

  void viewImage(BuildContext context, String imagePath, String panel) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black45,
      pageBuilder: (_, __, ___) => ImageDetailView(imagePath: imagePath, panel: panel),
    ));
  }
}

class ImageDetailView extends StatelessWidget {
  final String imagePath;
  final String panel;

  ImageDetailView({required this.imagePath, required this.panel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Hero(
            tag: "center_panel_$imagePath",
            child: InteractiveViewer(
              child: Image.file(File(imagePath)),
            ),
          ),
        ),
      ),
    );
  }
}
