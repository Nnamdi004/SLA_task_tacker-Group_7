class Task {
  int? id;

  String title;
  String description;
  String project;
  String assignee;
  String priority;
  DateTime startDate;
  DateTime deadline;
  String status;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.project,
    required this.assignee,
    required this.priority,
    required this.startDate,
    required this.deadline,
    required this.status,
  });
}
