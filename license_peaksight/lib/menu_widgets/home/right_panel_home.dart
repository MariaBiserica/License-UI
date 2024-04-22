import 'package:cloud_firestore/cloud_firestore.dart';
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

  void _addOrEditTask({Task? task}) {
    final TextEditingController titleController = TextEditingController(text: task?.title ?? '');
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String category = task?.category ?? 'Daily'; // Default to Daily if not specified
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task == null ? 'Add Task' : 'Edit Task'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  controller: titleController,
                  validator: (value) => value!.isEmpty ? 'Please enter a task title' : null,
                  decoration: InputDecoration(hintText: 'Task Title'),
                ),
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  value: category,
                  onChanged: (newValue) {
                    category = newValue!;
                  },
                  items: ['Daily', 'Weekly', 'Monthly']
                      .map((label) => DropdownMenuItem(
                            child: Text(label),
                            value: label,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (task == null) {
                    _addTask(titleController.text, 'new', category);
                  } else {
                    task.title = titleController.text;
                    task.category = category;
                    _editTask(task);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _addTask(String title, String status, String category) async {
    String? userId = _authService.getCurrentUserId();
    if (userId != null) {
      var newTask = Task(id: '', title: title, status: status, category: category);
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

  void _deleteTaskPrompt(String taskId) async {
    bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('Confirm Delete'),
              content: Text('Are you sure you want to delete this task?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Yes'),
                ),
              ],
            ));
    if (confirm) {
      _deleteTask(taskId);
    }
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
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) => _buildTaskCard(tasks[index], context),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: Constants.purpleDarkHome,
              onPressed: () => _addOrEditTask(),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, BuildContext context) {
    return Card(
      color: Constants.purpleDarkHome,
      elevation: 3,
      margin: EdgeInsets.only(top: Constants.kPaddingHome / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
      ),
      child: ListTile(
        title: Text(task.title, style: TextStyle(color: Colors.white)),
        subtitle: Text('Category: ${task.category}', style: TextStyle(color: Colors.white70)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.edit, color: Colors.white), onPressed: () => _addOrEditTask(task: task)),
            IconButton(icon: Icon(Icons.delete, color: Colors.white), onPressed: () => _deleteTaskPrompt(task.id)),
          ],
        ),
      ),
    );
  }
}