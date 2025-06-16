final class Task {
  final String id;
  final String title;
  final DateTime dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.isCompleted,
  });

  // Constructor for creating new tasks with auto-generated ID
  Task.create({
    required this.title,
    required this.dueDate,
    required this.isCompleted,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title'],
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'],
    );
  }
}
