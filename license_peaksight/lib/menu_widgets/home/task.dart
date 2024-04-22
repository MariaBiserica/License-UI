class Task {
  String id;
  String title;
  String status; // completed, queued, in progress, new
  String category; // Daily, Weekly, Monthly
  String description; // Description of the task

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
    this.description = '', // Default to an empty string if not provided
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      'category': category,
      'description': description,
    };
  }

  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'],
      status: map['status'],
      category: map['category'],
      description: map['description'] ?? '', // Handle nulls from the database
    );
  }
}
