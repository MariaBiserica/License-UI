import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:license_peaksight/constants.dart';
import 'package:license_peaksight/authentication/authentication_service.dart';
import 'package:license_peaksight/menu_widgets/home/chart_data.dart';
import 'package:license_peaksight/menu_widgets/home/task.dart';
import 'package:license_peaksight/menu_widgets/home/pie_chart_goals.dart';

class CenterPanelHome extends StatefulWidget {
  final Map<String, Color> themeColors;

  CenterPanelHome({required this.themeColors});

  @override
  _CenterPanelHomeState createState() => _CenterPanelHomeState();
}

class _CenterPanelHomeState extends State<CenterPanelHome> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
  }

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
        color: widget.themeColors['panelBackground'],
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
            StreamBuilder<List<ChartData>>(
              stream: taskStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      Text(
                        'Statistics',
                        style: TextStyle(
                          fontFamily: 'Voguella',
                          fontSize: 28, 
                          fontWeight: FontWeight.bold, 
                          color: widget.themeColors['textColor'],
                          shadows: [
                            Shadow( // Text shadow for better readability
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(150, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                      PieChartGoals(snapshot.data!),
                      Text(
                        'Recent Tasks',
                        style: TextStyle(
                          fontFamily: 'Voguella',
                          fontSize: 28, 
                          fontWeight: FontWeight.bold, 
                          color: widget.themeColors['textColor'],
                          shadows: [
                            Shadow( // Text shadow for better readability
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Color.fromARGB(150, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
            _buildRecentTasksWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTasksWidget() {
    return StreamBuilder<List<Task>>(
      stream: recentTasksStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return Card(
            color: widget.themeColors['panelForeground'],
            elevation: 3,
            margin: EdgeInsets.all(Constants.kPaddingHome / 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constants.borderRadius)),
            child: Column(
              children: snapshot.data!.map((task) => ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.title,
                      style: TextStyle(
                        color: widget.themeColors['textColor'],
                        fontSize: 16, // Larger font size for better visibility
                        fontWeight: FontWeight.bold, // Make text bold
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 4), // Space between title and status
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _statusColor(task.status), // Use status color
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        task.status.toUpperCase(), // Display status in uppercase
                        style: TextStyle(
                          color: widget.themeColors['textColor'],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  'Tap for details', // or use task.description for more details
                  style: TextStyle(color: widget.themeColors['detailsColor']),
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Task Details'),
                    content: Text('${task.description}'),
                  ),
                ),
              )).toList(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        return Text(
          "No recent tasks found",
          style: TextStyle(
            fontFamily: 'TellMeAJoke',
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: widget.themeColors['textColor'],
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
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

  Stream<List<Task>> recentTasksStream() async* {
    String? userId = _authService.getCurrentUserId();
    if (userId != null) {
      yield* FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .limit(5)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
    }
  }

}
