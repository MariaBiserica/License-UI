import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:license_peaksight/menu_widgets/home/chart_data.dart';

class PieChartGoals extends StatefulWidget {
  final List<ChartData> chartsData;

  PieChartGoals(this.chartsData);

  @override
  _PieChartGoalsState createState() => _PieChartGoalsState();
}

class _PieChartGoalsState extends State<PieChartGoals> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.chartsData.map((data) => _buildChartWithLegend(data)).toList(),
    );
  }

  Widget _buildChartWithLegend(ChartData data) {
    return Container(
      height: 200, // Set a fixed height for the chart and legend container
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              data.category + " Goals",
              style: TextStyle(
                fontFamily: 'Voguella',
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow( // Text shadow for better readability
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(150, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1, // Adjust size ratio as needed for the chart
                  child: _buildPieChart(data),
                ),
                Expanded(
                  flex: 1, // Adjust size ratio as needed for the legend
                  child: _buildLegend(data),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(ChartData data) {
    List<PieChartSectionData> sections = data.statusCounts.entries.map((entry) {
      final isTouched = touchedIndex == data.statusCounts.keys.toList().indexOf(entry.key);
      final fontSize = isTouched ? 18.0 : 16.0;
      final radius = isTouched ? 50.0 : 40.0;

      return PieChartSectionData(
        color: _getStatusColor(entry.key),
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize, 
          fontWeight: FontWeight.bold, 
          color: const Color(0xffffffff),
          shadows: [
            Shadow( // Text shadow for better readability
              offset: Offset(1.0, 1.0),
              blurRadius: 3.0,
              color: Color.fromARGB(150, 0, 0, 0),
            ),
          ],
        ),
      );
    }).toList();

    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (event is FlLongPressEnd || event is FlPanEndEvent) {
                touchedIndex = -1;
              } else {
                touchedIndex = pieTouchResponse?.touchedSection?.touchedSectionIndex ?? -1;
              }
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 0,
        sections: sections,
      ),
    );
  }

  Widget _buildLegend(ChartData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.statusCounts.entries.map((entry) => _legendItem(entry.key, _getStatusColor(entry.key))).toList(),
    );
  }

  Widget _legendItem(String status, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        SizedBox(width: 8),
        Text(status, style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'queued':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'new':
        return Colors.grey;
      default:
        return Colors.black; // Default color if none of the statuses match
    }
  }
}
