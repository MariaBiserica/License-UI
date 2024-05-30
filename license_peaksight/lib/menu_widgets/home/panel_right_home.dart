import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:license_peaksight/app_bar/notification_service.dart';
import 'package:license_peaksight/constants.dart';
import 'package:license_peaksight/authentication/authentication_service.dart';
import 'package:license_peaksight/menu_widgets/home/task.dart';

class RightPanelHome extends StatefulWidget {
  final ValueNotifier<List<NotificationCustom>> notifications; // Notifications list
  final Function(NotificationCustom) onRestore; // Callback to restore task
  final GlobalKey<RightPanelHomeState> key;
  final Map<String, Color> themeColors;

  RightPanelHome({
    required this.notifications, 
    required this.onRestore, 
    required this.key,
    required this.themeColors,
  });
  
  @override
  RightPanelHomeState createState() => RightPanelHomeState();
}

class RightPanelHomeState extends State<RightPanelHome> {
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

  void _addNotification(Task task, String message) {
    widget.notifications.value = List.from(widget.notifications.value)
      ..add(NotificationCustom(
        id: DateTime.now().toIso8601String(),
        message: message,
        task: task,
        timestamp: DateTime.now(),
      ));
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
    var task = tasks.firstWhere((task) => task.id == taskId);
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).delete();
    _fetchTasks();
    _addNotification(task, "Task '${task.title}' deleted");
  }
  
  void restoreTask(Task task) async {
    String? userId = _authService.getCurrentUserId();
    if (userId != null) {
      var docRef = await FirebaseFirestore.instance.collection('tasks').add({
        ...task.toMap(),
        'userId': userId,
      });
      task.id = docRef.id;  // Update the local task id with the new document ID
      setState(() {
        tasks.add(task);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: Constants.kPaddingHome),
          Text(
            'Tasks & Goals',
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
          SizedBox(height: Constants.kPaddingHome),
          Expanded( // This will contain the scrollable part
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildCategoryTasks("Daily"),
                  _buildCategoryTasks("Weekly"),
                  _buildCategoryTasks("Monthly"),
                ],
              ),
            ),
          ),
          SizedBox(height: Constants.kPaddingHome),
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              backgroundColor: widget.themeColors['panelForeground'],
              onPressed: () => _addOrEditTask(),
              child: Icon(Icons.add, color: widget.themeColors['textColor']),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTasks(String category) {
    List<Task> categoryTasks = tasks.where((task) => task.category == category).toList();
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),  // Adds space between category tiles
      decoration: BoxDecoration(
        color: widget.themeColors['panelForeground'], 
        borderRadius: BorderRadius.circular(Constants.borderRadius),  // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),  // Shadow effect
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            "$category Goals",
            style: TextStyle(
              color: widget.themeColors['textColor'],
              //fontWeight: FontWeight.bold,
              shadows: [
                Shadow( // Text shadow for better readability
                  offset: Offset(1.0, 1.0),
                  blurRadius: 3.0,
                  color: Color.fromARGB(150, 0, 0, 0),
                ),
              ],
              fontFamily: 'Rastaglion',  // Custom font applied
              fontSize: 20,  // Slightly larger font size
            ),
          ),
          children: categoryTasks.map((task) => _buildTaskCard(task, context)).toList(),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, BuildContext context) {
    return Card(
      color: widget.themeColors['panelForeground'],
      elevation: 3,
      margin: EdgeInsets.only(top: Constants.kPaddingHome / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.borderRadius),
      ),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              task.title,
              style: TextStyle(
                color: widget.themeColors['textColor'],
                fontSize: 16, // Larger font size for better visibility
                fontWeight: FontWeight.bold, // Make text bold
                shadows: [
                  Shadow( // Text shadow for better readability
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(150, 0, 0, 0),
                  ),
                ],
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
          task.description,
          style: TextStyle(
            color: Colors.white70,
            overflow: TextOverflow.ellipsis, // Use ellipsis for text overflow
          ),
          maxLines: 3, // Limit the number of lines for the description
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.edit, color: widget.themeColors['textColor']), onPressed: () => _addOrEditTask(task: task)),
            IconButton(icon: Icon(Icons.delete, color: widget.themeColors['textColor']), onPressed: () => _deleteTaskPrompt(task.id)),
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