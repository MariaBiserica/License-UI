import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:license_peaksight/constants.dart';
import 'package:license_peaksight/authentication/authentication_service.dart';
import 'package:license_peaksight/menu_widgets/home/task.dart';

class LeftPanelHome extends StatefulWidget {
  final Map<String, Color> themeColors;

  LeftPanelHome({required this.themeColors});

  @override
  _LeftPanelHomeState createState() => _LeftPanelHomeState();
}

class _LeftPanelHomeState extends State<LeftPanelHome> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(Constants.kPaddingHome / 2),
          margin: EdgeInsets.all(Constants.kPaddingHome), // Adds margin around the container
          decoration: BoxDecoration(
            color: widget.themeColors['panelBackground'],
            borderRadius: BorderRadius.circular(Constants.borderRadius), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 20,
                offset: Offset(0, 10), // Changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: Constants.kPaddingHome),
              Text(
                'Quick Access',
                style: TextStyle(
                  fontFamily: 'HeaderFont', 
                  fontSize: 34, 
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
              StreamBuilder(
                stream: _taskStream(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    int completedTasks = 0;
                    int inProgressTasks = 0;
                    int queuedTasks = 0;

                    snapshot.data!.docs.forEach((doc) {
                      Task task = Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
                      if (task.status == 'completed') {
                        completedTasks++;
                      } else if (task.status == 'in progress') {
                        inProgressTasks++;
                      } else if (task.status == 'queued') {
                        queuedTasks++;
                      }
                    });

                    return _buildStatsOverview(completedTasks, inProgressTasks, queuedTasks);
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<QuerySnapshot> _taskStream() {
    String? userId = _authService.getCurrentUserId();
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Widget _buildStatsOverview(int completedTasks, int inProgressTasks, int queuedTasks) {
    return Card(
      color: widget.themeColors['panelForeground'],
      elevation: 3,
      margin: EdgeInsets.all(Constants.kPaddingHome / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Constants.kPaddingHome / 2),
        child: Column(
          children: [
            Text(
              'Stats Overview',
              style: TextStyle(
                fontFamily: 'Rastaglion',
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: widget.themeColors['textColor'],
              ),
            ),
            Divider(color: widget.themeColors['dividerColor']),
            _buildStatItem("Tasks Completed", completedTasks.toString()),
            _buildStatItem("Tasks In Progress", inProgressTasks.toString()),
            _buildStatItem("Tasks Queued", queuedTasks.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(  // Makes the title flexible, wrapping text if needed
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Voguella',
                fontSize: 16,
                color: widget.themeColors['textColor'],
              ),
              overflow: TextOverflow.fade,  // Prevents text from overflowing
            ),
          ),
          SizedBox(width: 10), // Adds space between title and value
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: widget.themeColors['panelForeground'],
              borderRadius: BorderRadius.circular(10), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5), // Shadow with some opacity
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1), // Position of shadow
                ),
              ],
            ),
            child: Text(
              value, 
              style: TextStyle(
                color: widget.themeColors['textColor'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
