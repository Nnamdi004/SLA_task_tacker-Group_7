// Shared Task model used by every screen, the database and the SLA logic.

enum SlaStatus { onTrack, atRisk, overdue, completed }

extension SlaStatusLabel on SlaStatus {
  String get label => switch (this) {
        SlaStatus.onTrack => 'On Track',
        SlaStatus.atRisk => 'At Risk',
        SlaStatus.overdue => 'Overdue',
        SlaStatus.completed => 'Completed',
      };
}

class Task {
  int? id;

  String title;
  String description;
  String project;
  String assignee;
  String priority; // 'Low' | 'Medium' | 'High'
  DateTime startDate;
  DateTime deadline;
  String status; // 'To Do' | 'In Progress' | 'Completed'

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

  bool get isCompleted => status == 'Completed';

  /// The deadline is picked as a date (no time), so a task is due at the END
  /// of that day.
  DateTime get dueAt =>
      DateTime(deadline.year, deadline.month, deadline.day, 23, 59, 59);

  /// SLA rules (explain these in the demo). The first match wins:
  /// 1. Completed task                          -> Completed
  /// 2. Not completed and the due time passed   -> Overdue
  /// 3. Not completed and due within 24 hours   -> At Risk
  /// 4. Anything else                           -> On Track
  SlaStatus sla(DateTime now) {
    if (isCompleted) return SlaStatus.completed;
    final due = dueAt;
    if (now.isAfter(due)) return SlaStatus.overdue;
    if (due.difference(now) <= const Duration(hours: 24)) {
      return SlaStatus.atRisk;
    }
    return SlaStatus.onTrack;
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? project,
    String? assignee,
    String? priority,
    DateTime? startDate,
    DateTime? deadline,
    String? status,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      project: project ?? this.project,
      assignee: assignee ?? this.assignee,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
    );
  }
}