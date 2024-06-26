class Task {
  String id;
  String title;
  String status; // completed, queued, in progress, new
  String category; // Daily, Weekly, Monthly
  String description; // Description of the task
  String? creationDate; // Date the task was created, nullable

  Task({
    required this.id,
    required this.title,
    required this.status,
    required this.category,
    this.description = '', // Default to an empty string if not provided
    this.creationDate, // Nullable creation date
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'status': status,
      'category': category,
      'description': description,
      'creationDate': creationDate, // Store as a string
    };
  }

  static Task fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      title: map['title'],
      status: map['status'],
      category: map['category'],
      description: map['description'] ?? '', // Handle nulls from the database
      creationDate: map['creationDate'], // Handle null or missing creationDate
    );
  }
}
