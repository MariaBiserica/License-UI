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

  Stream<List<ChartData>> taskStream() async* {
    String? userId = _authService.getCurrentUserId();
    if (userId != null) {
      yield* FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
            Map<String, Map<String, int>> categoryData = {};
            for (var doc in snapshot.docs) {
              Task task = Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              categoryData[task.category] = categoryData[task.category] ?? {};
              categoryData[task.category]?[task.status] = (categoryData[task.category]?[task.status] ?? 0) + 1;
            }
            return categoryData.entries.map((entry) => ChartData(entry.key, entry.value)).toList();
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
      child: SingleChildScrollView(
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
                color: Colors.white),
            ),
            StreamBuilder<List<ChartData>>(
              stream: taskStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
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
                      PieChartGoals(snapshot.data!),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
