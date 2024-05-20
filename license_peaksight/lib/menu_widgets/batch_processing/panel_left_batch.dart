import 'dart:math';

import 'package:flutter/material.dart';
import 'package:license_peaksight/constants.dart';
import 'package:fl_chart/fl_chart.dart';

class PanelLeftBatchProcessing extends StatefulWidget {
  final Function(String) onMetricSelected;
  final List<double> scores;

  PanelLeftBatchProcessing({required this.onMetricSelected, required this.scores});

  @override
  _PanelLeftBatchProcessingState createState() => _PanelLeftBatchProcessingState();
}

class _PanelLeftBatchProcessingState extends State<PanelLeftBatchProcessing> {
  String selectedMetric = 'Noise';
  String? selectedOverallQualityMetric;
  bool isOverallQualitySelected = false;
  bool showChart = false;

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

  void toggleChart() {
    setState(() {
      showChart = !showChart;
    });
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
                color: Constants.purpleLight,
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
                            fontFamily: 'MOXABestine',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Constants.kPadding),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth - 2 * Constants.kPadding,
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
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
                        ),
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Constants.kPadding),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: constraints.maxWidth - 2 * Constants.kPadding,
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
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
                          ),
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
                      ElevatedButton(
                        onPressed: toggleChart,
                        child: Text(showChart ? 'Hide Data Distribution' : 'Show Data Distribution', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.panelForeground,
                        ),
                      ),
                      if (showChart) buildLineChart(), // Conditionally show the chart
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

  Widget buildLineChart() {
    return Container(
      height: 250, // Set a fixed height for the chart
      padding: const EdgeInsets.all(Constants.kPadding),
      child: Scrollbar(
        thumbVisibility: true, // Ensure the thumb is always visible
        controller: _scrollController,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, // Enable horizontal scrolling
          controller: _scrollController,
          child: Container(
            width: widget.scores.length * 30.0, // Adjust width based on number of scores
            child: Card(
              color: Constants.purpleLight,
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(Constants.kPadding, Constants.kPadding * 6, Constants.kPadding, Constants.kPadding),
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
                          reservedSize: 30,
                          interval: 1,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            const style = TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16);
                            switch (value.toInt()) {
                              case 1:
                                return SideTitleWidget(axisSide: meta.axisSide, child: Text('1', style: style));
                              case 2:
                                return SideTitleWidget(axisSide: meta.axisSide, child: Text('2', style: style));
                              case 3:
                                return SideTitleWidget(axisSide: meta.axisSide, child: Text('3', style: style));
                              case 4:
                                return SideTitleWidget(axisSide: meta.axisSide, child: Text('4', style: style));
                              case 5:
                                return SideTitleWidget(axisSide: meta.axisSide, child: Text('5', style: style));
                              default:
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
                    maxX: widget.scores.length.toDouble(),
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
