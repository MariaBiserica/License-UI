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
      height: 200, // Define a fixed height for the row containing the pie chart and legend
      child: Row(
        children: [
          Expanded(
            flex: 1, // Proportion for the pie chart
            child: _buildPieChart(data),
          ),
          Expanded(
            flex: 1, // Proportion for the legend
            child: _buildLegend(data),
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
        titleStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
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
