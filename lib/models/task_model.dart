

class Task {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final String priority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.priority,
  });

  // Factory constructor to create a Task instance from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      priority: json['priority'],
    );
  }

  // Method to convert Task instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'priority': priority, // Convert enum to string
    };
  }
}