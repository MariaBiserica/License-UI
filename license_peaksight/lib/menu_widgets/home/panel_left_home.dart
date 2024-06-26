import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
                  shadows: [
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
              _buildRecentTasksTitle(),
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
      margin: EdgeInsets.symmetric(vertical: Constants.kPaddingHome / 2),
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
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: widget.themeColors['textColor'],
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            Divider(color: widget.themeColors['dividerColor']),
            _buildStatItem("Tasks Completed", completedTasks.toString()),
            _buildStatItem("Tasks in Progress", inProgressTasks.toString()),
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
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Rastsaglion',
                fontSize: 18,
                color: widget.themeColors['textColor'],
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              overflow: TextOverflow.fade,
            ),
          ),
          SizedBox(width: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: widget.themeColors['panelForeground'],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1),
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

  Widget _buildRecentTasksTitle() {
    return Card(
      color: widget.themeColors['panelForeground'],
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: Constants.kPaddingHome / 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constants.borderRadius)),
      child: Padding(
        padding: EdgeInsets.all(Constants.kPaddingHome / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Recent Tasks',
              style: TextStyle(
                fontFamily: 'Rastaglion',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: widget.themeColors['textColor'],
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            Divider(color: widget.themeColors['dividerColor']),
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
            elevation: 5,
            margin: EdgeInsets.all(Constants.kPaddingHome / 4),
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
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (task.creationDate != null) // Check for null
                      Text(
                        'Timestamp: ${DateFormat('dd/MM/yyyy - HH:mm:ss').format(DateTime.parse(task.creationDate!))}', // Display creation date
                        style: TextStyle(color: widget.themeColors['detailsColor']),
                      ),
                    Text(
                      'Tap for details', // or use task.description for more details
                      style: TextStyle(color: widget.themeColors['detailsColor']),
                    ),
                  ],
                ),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: widget.themeColors['panelForeground'], // Set modal background color to theme color
                    child: Container(
                      height: 300, // Set the fixed height of the dialog
                      width: 300, // Set the fixed width of the dialog
                      decoration: BoxDecoration(
                        color: widget.themeColors['panelForeground'],
                        borderRadius: BorderRadius.circular(Constants.borderRadius), // Add rounded corners
                      ),
                      child: AlertDialog(
                        backgroundColor: widget.themeColors['panelForeground'], // Set modal background color to theme color
                        title: Text(
                          'Task Details',
                          style: TextStyle(color: widget.themeColors['textColor']), // Set title text color to theme color
                        ),
                        content: SingleChildScrollView( // Makes the content scrollable
                          child: Text(
                            '${task.description}',
                            style: TextStyle(color: widget.themeColors['textColor']), // Set content text color to theme color
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Close', style: TextStyle(color: widget.themeColors['textColor'])), // Set button text color to theme color
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )).toList(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        return Text(
          "No recent tasks found.",
          style: TextStyle(
            fontSize: 15,
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
          .orderBy('creationDate', descending: true) // Order by creation date
          .limit(5)
          .snapshots()
          .map((snapshot) => snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
    }
  }
}
