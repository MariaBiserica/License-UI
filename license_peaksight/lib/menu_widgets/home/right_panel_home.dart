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
    final TextEditingController descriptionController = TextEditingController(text: task?.description ?? '');
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    String category = task?.category ?? 'Daily'; // Default to Daily if not specified
    String status = task?.status ?? 'new'; // Default to 'new' if not specified

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task == null ? 'Add Task' : 'Edit Task'),
          content: Container(
            width: double.minPositive, // Ensures the dialog is only as wide as the content needs it to be
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: titleController,
                    validator: (value) => value!.isEmpty ? 'Please enter a task title' : null,
                    decoration: InputDecoration(hintText: 'Task Title'),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(hintText: 'Description'),
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
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    value: status,
                    onChanged: (newValue) {
                      status = newValue!;
                    },
                    items: ['new', 'in progress', 'queued', 'completed']
                        .map((label) => DropdownMenuItem(
                              child: Text(label),
                              value: label,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (task == null) {
                    _addTask(titleController.text, status, category, descriptionController.text);
                  } else {
                    task.title = titleController.text;
                    task.description = descriptionController.text;
                    task.category = category;
                    task.status = status;
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

  void _addTask(String title, String status, String category, String description) async {
    String? userId = _authService.getCurrentUserId();
    if (userId != null) {
      var newTask = Task(id: '', title: title, status: status, category: category, description: description);
      var docRef = await FirebaseFirestore.instance.collection('tasks').add({
        ...newTask.toMap(),
        'userId': userId,
      });
      newTask.id = docRef.id;  // Update the local task id with the new document ID
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
      margin: EdgeInsets.all(Constants.kPaddingHome),
      decoration: BoxDecoration(
        color: Constants.purpleLightHome,
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
            'Tasks & Goals',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: Constants.kPaddingHome),
          _buildCategoryTasks("Daily"),
          _buildCategoryTasks("Weekly"),
          _buildCategoryTasks("Monthly"),
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

  Widget _buildCategoryTasks(String category) {
    List<Task> categoryTasks = tasks.where((task) => task.category == category).toList();
    return ExpansionTile(
      title: Text("$category Goals", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      children: categoryTasks.map((task) => _buildTaskCard(task, context)).toList(),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(task.title, style: TextStyle(color: Colors.white)),
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
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '${task.description}',
          style: TextStyle(color: Colors.white70),
          maxLines: 3,
          overflow: TextOverflow.fade,
        ),
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

}