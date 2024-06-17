import 'dart:math';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:license_peaksight/constants.dart';
import 'package:fl_chart/fl_chart.dart';

class PanelLeftBatchProcessing extends StatefulWidget {
  final Function(String) onMetricSelected;
  final List<double> scores;
  final List<String> imagePaths;
  final Map<String, Color> themeColors;

  PanelLeftBatchProcessing({
    required this.onMetricSelected,
    required this.scores,
    required this.imagePaths,
    required this.themeColors,
  });

  @override
  _PanelLeftBatchProcessingState createState() => _PanelLeftBatchProcessingState();
}

class _PanelLeftBatchProcessingState extends State<PanelLeftBatchProcessing> {
  String selectedMetric = 'Noise';
  String? selectedOverallQualityMetric;
  bool isOverallQualitySelected = false;

  final ScrollController _scrollController = ScrollController();

  void startAnalysis() {
    if (isOverallQualitySelected && selectedOverallQualityMetric != null) {
      print("Selected overall quality metric: $selectedOverallQualityMetric");
      widget.onMetricSelected(selectedOverallQualityMetric!);
    } else {
      print("Selected metric: $selectedMetric");
      widget.onMetricSelected(selectedMetric);
    }
  }

  void showChartDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6, // Set the width of the dialog
            padding: EdgeInsets.all(Constants.kPadding),
            decoration: BoxDecoration(
              color: widget.themeColors['panelBackground'],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Data Distribution",
                  style: TextStyle(
                    fontFamily: 'HeaderFont',
                    fontSize: 25,
                    color: widget.themeColors['textColor'],
                  ),
                ),
                SizedBox(height: 20),
                buildLineChart(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: showClassificationStats,
                  child: Text(
                    'Show Classification Stats',
                    style: TextStyle(color: widget.themeColors['textColor']),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColors['panelForeground'],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(color: widget.themeColors['textColor']),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.themeColors['panelForeground'],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showClassificationStats() {
    Map<String, int> classificationCounts = {
      'Excellent': 0,
      'Good': 0,
      'Fair': 0,
      'Poor': 0,
      'Bad': 0,
      'Outlier': 0,
    };

    for (var score in widget.scores) {
      if (score > 5 || score < 1) classificationCounts['Outlier'] = classificationCounts['Outlier']! + 1;
      else if (score > 4 && score <= 5) classificationCounts['Excellent'] = classificationCounts['Excellent']! + 1;
      else if (score > 3 && score <= 4) classificationCounts['Good'] = classificationCounts['Good']! + 1;
      else if (score > 2 && score <= 3) classificationCounts['Fair'] = classificationCounts['Fair']! + 1;
      else if (score > 1.50 && score <= 2) classificationCounts['Poor'] = classificationCounts['Poor']! + 1;
      else classificationCounts['Bad'] = classificationCounts['Bad']! + 1;
    }

    int total = widget.scores.length;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: widget.themeColors['panelBackground'],
          title: Text("Classification Stats", style: TextStyle(color: widget.themeColors['textColor'])),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: classificationCounts.entries.map((entry) {
              double percentage = (entry.value / total) * 100;
              return Text(
                "${entry.key}: ${percentage.toStringAsFixed(2)}%",
                style: TextStyle(color: widget.themeColors['textColor']),
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Close", style: TextStyle(color: widget.themeColors['textColor'])),
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Container(
              padding: const EdgeInsets.all(Constants.kPadding),
              child: Card(
                color: widget.themeColors['panelBackground'],
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(Constants.kPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(Constants.kPadding),
                        child: Text(
                          "Control Center",
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: Constants.kPadding),
                        child: Text(
                          "Select which metric to assess:",
                          style: TextStyle(
                            fontSize: 15,
                            color: widget.themeColors['subtitleColor'],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Constants.kPadding),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth - 2 * Constants.kPadding,
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedMetric,
                            icon: Icon(Icons.arrow_downward, color: widget.themeColors['textColor']),
                            dropdownColor: widget.themeColors['panelBackground'],
                            underline: Container(height: 2, color: widget.themeColors['textColor']),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedMetric = newValue!;
                                isOverallQualitySelected = newValue == 'Overall Quality';
                                selectedOverallQualityMetric = null; // Reset secondary selection if metric changes
                              });
                            },
                            items: getDropdownMenuItems(),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      if (isOverallQualitySelected) ...[
                        Text(
                          "Select detailed quality metric:",
                          style: TextStyle(
                            fontFamily: 'Voguella',
                            fontSize: 14,
                            color: widget.themeColors['textColor'],
                          ),
                        ),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Constants.kPadding),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth - 2 * Constants.kPadding,
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedOverallQualityMetric,
                              icon: Icon(Icons.arrow_downward, color: widget.themeColors['textColor']),
                              dropdownColor: widget.themeColors['panelBackground'],
                              underline: Container(height: 2, color: widget.themeColors['textColor']),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedOverallQualityMetric = newValue!;
                                });
                              },
                              items: getQualityDropdownItems(),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                      ElevatedButton(
                        onPressed: startAnalysis,
                        child: Text('Start Analysis', style: TextStyle(color: widget.themeColors['textColor'])),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.themeColors['panelForeground'],
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: showChartDialog,
                        child: Text(
                          'Show Data Distribution',
                          style: TextStyle(color: widget.themeColors['textColor']),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.themeColors['panelForeground'],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
      'Overall Quality': Icons.score,
    };

    return icons.keys.map((String key) {
      return DropdownMenuItem<String>(
        value: key,
        child: Row(
          children: [
            Icon(icons[key], color: widget.themeColors['textColor']),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                key,
                style: TextStyle(fontSize: 15, color: widget.themeColors['textColor']),
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
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
      'BIQA Noise Stats': Icons.filter_5,
    };

    return icons.keys.map((String key) {
      return DropdownMenuItem<String>(
        value: key,
        child: Row(
          children: [
            Icon(icons[key], color: widget.themeColors['textColor']),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                key,
                style: TextStyle(fontSize: 15, color: widget.themeColors['textColor']),
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget buildLineChart() {
    return Container(
      height: 250, // Set a fixed height for the chart
      padding: const EdgeInsets.all(Constants.kPadding),
      child: Scrollbar(
        thumbVisibility: true, // Ensure the thumb is always visible
        controller: _scrollController,
        thickness: 15, // Increase the thickness of the scrollbar
        radius: Radius.circular(10), // Make the scrollbar rounded
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enable horizontal scrolling
          controller: _scrollController,
          child: Container(
            width: widget.scores.length * 50.0, // Adjust width based on number of scores
            child: Card(
              color: widget.themeColors['panelBackground'],
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Constants.kPadding, Constants.kPadding * 6, Constants.kPadding * 3, Constants.kPadding),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(color: Constants.blue, strokeWidth: 1);
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(color: Constants.blue, strokeWidth: 1);
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          interval: 1,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10);
                            if (value.toInt() < widget.imagePaths.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 10, // Add space above the text
                                child: Transform.rotate(
                                  angle: -pi / 7, // Rotate the text by 45 degrees
                                  child: Text(path.basename(widget.imagePaths[value.toInt()]), style: style),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15);
                            switch (value.toInt()) {
                              case 1:
                                return Text('1', style: style, textAlign: TextAlign.left);
                              case 2:
                                return Text('2', style: style, textAlign: TextAlign.left);
                              case 3:
                                return Text('3', style: style, textAlign: TextAlign.left);
                              case 4:
                                return Text('4', style: style, textAlign: TextAlign.left);
                              case 5:
                                return Text('5', style: style, textAlign: TextAlign.left);
                              default:
                                return Container();
                            }
                          },
                          reservedSize: 42,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d)),
                    ),
                    minX: 0,
                    maxX: widget.scores.length.toDouble() - 1,
                    minY: 0,
                    maxY: 5,
                    lineBarsData: [
                      LineChartBarData(
                        spots: widget.scores.asMap().entries.map((entry) {
                          return FlSpot(entry.key.toDouble(), entry.value);
                        }).toList(),
                        isCurved: true,
                        gradient: LinearGradient(colors: [Color(0xff23b6e6), Color(0xff02d39a)]),
                        barWidth: 5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [Color(0xff23b6e6).withOpacity(0.3), Color(0xff02d39a).withOpacity(0.3)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
