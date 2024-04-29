import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:license_peaksight/menu_widgets/home/chart_data.dart';

class PieChartGoals extends StatelessWidget {
  final List<ChartData> chartsData;

  PieChartGoals(this.chartsData);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: chartsData.map((data) => _buildChartWithLegend(data)).toList(),
    );
  }

  Widget _buildChartWithLegend(ChartData data) {
    return Row(
      children: [
        Expanded(
          flex: 1, // Adjust size ratio as needed
          child: _buildPieChart(data),
        ),
        Expanded(
          flex: 1, // Adjust size ratio as needed
          child: _buildLegend(data),
        ),
      ],
    );
  }

  Widget _buildPieChart(ChartData data) {
    List<PieChartSectionData> sections = data.statusCounts.entries.map((entry) {
      return PieChartSectionData(
        color: _getStatusColor(entry.key),
        value: entry.value.toDouble(),
        title: '${entry.value}',
        radius: 40,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xffffffff)),
      );
    }).toList();

    return Container(
      height: 200, // Set height to avoid sizing issues
      child: PieChart(
        PieChartData(
          sections: sections,
          borderData: FlBorderData(show: false),
          centerSpaceRadius: 0,
          sectionsSpace: 2,
        ),
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
        Icon(Icons.circle, color: color, size: 12), // Circle icon to represent color
        SizedBox(width: 8),
        Text(status, style: TextStyle(color: Colors.white)), // Status text
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
