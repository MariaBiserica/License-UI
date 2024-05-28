import 'package:license_peaksight/menu_widgets/home/task.dart';

class NotificationCustom {
  final String id;
  final String message;
  final Task task; // Task associated with the notification
  final DateTime timestamp;

  NotificationCustom({
    required this.id,
    required this.message,
    required this.task,
    required this.timestamp,
  });
}
