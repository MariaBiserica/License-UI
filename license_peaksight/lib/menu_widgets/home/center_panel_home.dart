import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:license_peaksight/constants.dart';
import 'package:license_peaksight/authentication/authentication_service.dart';
import 'package:license_peaksight/menu_widgets/home/chart_data.dart';
import 'package:license_peaksight/menu_widgets/home/task.dart';
import 'package:license_peaksight/menu_widgets/home/pie_chart_goals.dart';

class CenterPanelHome extends StatefulWidget {
  @override
  _CenterPanelHomeState createState() => _CenterPanelHomeState();
}

class _CenterPanelHomeState extends State<CenterPanelHome> {
  final AuthService _authService = AuthService();
  List<ChartData> chartsData = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  void fetchTasks() async {
    String? userId = _authService.getCurrentUserId();
    if (userId != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();

      Map<String, Map<String, int>> categoryData = {};

      snapshot.docs.forEach((doc) {
        Task task = Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        categoryData[task.category] = categoryData[task.category] ?? {};
        categoryData[task.category]?[task.status] = (categoryData[task.category]?[task.status] ?? 0) + 1;
      });

      List<ChartData> tempData = categoryData.entries.map((entry) {
        return ChartData(entry.key, entry.value);
      }).toList();

      setState(() {
        chartsData = tempData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Constants.kPaddingHome / 2),
      margin: EdgeInsets.all(Constants.kPaddingHome),
      decoration: BoxDecoration(
        color: Constants.panelBackground,
        borderRadius: BorderRadius.circular(Constants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SingleChildScrollView( // To ensure the content is scrollable if it overflows
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: Constants.kPaddingHome),
            Text(
              'Dashboard', 
              style: TextStyle(
                fontFamily: 'MOXABestine', 
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: Colors.white
                ),
              ),
            _buildStatisticsWidgets(),
            //_buildRecentTasksWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsWidgets() {
    return Column(
      children: [
        Text(
          'Statistics',
          style: TextStyle(
            fontFamily: 'MOXABestine',
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Colors.white),
        ),
        if (chartsData.isNotEmpty) 
          PieChartGoals(chartsData),
      ],
    );
  }

  Widget _buildRecentTasksWidget() {
    // Placeholder for recent tasks widget
    return Expanded(
      child: ListView.builder(
        itemCount: 5, // Example count of tasks
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("Task $index", style: TextStyle(color: Colors.white)),
            subtitle: Text("Status: Completed", style: TextStyle(color: Colors.green)),
            onTap: () {
              // Example of action on tap
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Task Details'),
                  content: Text('Details of Task $index here.'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
