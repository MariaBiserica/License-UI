class Task {
  String id;
  String title;
  String status; // completed, queued, in progress, new

  Task({required this.id, required this.title, required this.status});

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
    };
  }

  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'],
      status: map['status'],
    );
  }
}
