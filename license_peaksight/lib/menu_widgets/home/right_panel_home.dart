import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:license_peaksight/constants.dart';
import 'package:license_peaksight/authentication/authentication_service.dart';
import 'package:license_peaksight/menu_widgets/home/task.dart';


class RightPanelHome extends StatefulWidget {
  @override
  _RightPanelHomeState createState() => _RightPanelHomeState();
}

class _RightPanelHomeState extends State<RightPanelHome> {
  final AuthService _authService = AuthService();
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() async {
    String? userId = _authService.getCurrentUserId();
    if (userId != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();
      var tasksData = snapshot.docs
          .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      setState(() {
        tasks = tasksData;
      });
    }
  }

  void _addTask(String title, String status) async {
    String? userId = _authService.getCurrentUserId();
    if (userId != null) {
      var newTask = Task(id: '', title: title, status: status);
      var docRef = await FirebaseFirestore.instance.collection('tasks').add({
        ...newTask.toMap(),
        'userId': userId,
      });
      newTask.id = docRef.id; // Update the local task id with the new document ID
      setState(() {
        tasks.add(newTask);
      });
    }
  }

  void _editTask(Task task) async {
    await FirebaseFirestore.instance
        .collection('tasks')
        .doc(task.id)
        .update(task.toMap());
    _fetchTasks();
  }

  void _deleteTask(String taskId) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
    _fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Constants.kPaddingHome / 2),
      margin: EdgeInsets.all(Constants.kPaddingHome), // Adds margin around the container
      decoration: BoxDecoration(
        color: Constants.purpleLightHome,
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
            'Tasks & Goals',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: Constants.kPaddingHome),
          _buildTaskCard('Daily Goals', context),
          _buildTaskCard('Weekly Goals', context),
          _buildTaskCard('Monthly Goals', context),
          Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: Constants.purpleDarkHome,
              onPressed: () {
                // Add new task logic
              },
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String title, BuildContext context) {
    return Card(
      color: Constants.purpleDarkHome,
      elevation: 3,
      margin: EdgeInsets.only(top: Constants.kPaddingHome / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
      ),
      child: ExpansionTile(
        title: Text(title, style: TextStyle(color: Colors.white)),
        children: [
          ListTile(
            title: Text('Task 1', style: TextStyle(color: Colors.white)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit, color: Colors.white), onPressed: () {}),
                IconButton(icon: Icon(Icons.delete, color: Colors.white), onPressed: () {}),
              ],
            ),
          ),
          // Add more ListTiles as needed
        ],
      ),
    );
  }
}
