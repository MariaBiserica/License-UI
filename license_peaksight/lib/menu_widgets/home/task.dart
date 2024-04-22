class Task {
  String id;
  String title;
  String status; // completed, queued, in progress, new
  String category; // Daily, Weekly, Monthly

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      'category': category,
    };
  }

  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'],
      status: map['status'],
      category: map['category'],
    );
  }
}
