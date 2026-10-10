import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskForm extends StatefulWidget {
  final Task? task;
  final bool isEdit;
  final ValueChanged<Task> onSave;

  const TaskForm({
    super.key,
    this.task,
    this.isEdit = false,
    required this.onSave,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  late String project;
  late String assignee;
  late String priority;
  late String status;

  late DateTime startDate;
  late DateTime deadlineDate;

  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final task = widget.task;

    titleController = TextEditingController(text: task?.title ?? '');

    descriptionController = TextEditingController(
      text:
          task?.description ??
          'Prepare the release tasks and make sure everything is ready.',
    );

    project = task?.project ?? 'Atlas release';
    assignee = task?.assignee ?? 'Liata Ornella';
    priority = task?.priority ?? 'Medium';
    status = task?.status ?? 'To Do';

    startDate = task?.startDate ?? DateTime(2026, 10, 3);
    deadlineDate = task?.deadline ?? DateTime(2026, 10, 10);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> selectDate({required bool isStartDate}) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : deadlineDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      if (isStartDate) {
        startDate = selectedDate;
      } else {
        deadlineDate = selectedDate;
      }
    });
  }

  void saveTask() {
    setState(() {
      errorMessage = null;
    });

    final title = titleController.text.trim();

    if (title.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a task title.';
      });
      return;
    }

    if (deadlineDate.isBefore(startDate)) {
      setState(() {
        errorMessage = 'Deadline cannot be before the start date.';
      });
      return;
    }

    final updatedTask = Task(
      id: widget.task?.id,
      title: title,
      description: descriptionController.text.trim(),
      project: project,
      assignee: assignee,
      priority: priority,
      startDate: startDate,
      deadline: deadlineDate,
      status: status,
    );

    widget.onSave(updatedTask);

    Navigator.of(context).pop();
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Title',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: 'Enter task title',
              errorText:
                  errorMessage != null && titleController.text.trim().isEmpty
                  ? 'Title is required'
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Description',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter task description',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Project',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),

          const SizedBox(height: 8),

          _dropdown(
            value: project,
            items: const ['Atlas release', 'Website', 'Mobile App', 'Backend'],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  project = value;
                });
              }
            },
          ),

          const SizedBox(height: 18),

          const Text(
            'Assignee',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),

          const SizedBox(height: 8),

          _dropdown(
            value: assignee,
            items: const ['Nnamdi Onugha', 'Liata Ornella', 'Divine Mutesi', 'Tumba II Kongolo'],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  assignee = value;
                });
              }
            },
          ),

          const SizedBox(height: 18),

          const Text(
            'Priority',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _priorityButton('Low'),
              const SizedBox(width: 8),
              _priorityButton('Medium'),
              const SizedBox(width: 8),
              _priorityButton('High'),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'Dates',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: _dateField(
                  label: 'Start date',
                  date: startDate,
                  onTap: () {
                    selectDate(isStartDate: true);
                  },
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _dateField(
                  label: 'Deadline',
                  date: deadlineDate,
                  onTap: () {
                    selectDate(isStartDate: false);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'Status',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),

          const SizedBox(height: 8),

          _dropdown(
            value: status,
            items: const ['To Do', 'In Progress', 'Completed'],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  status = value;
                });
              }
            },
          ),

          if (errorMessage != null) ...[
            const SizedBox(height: 15),

            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 20),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: saveTask,
                  child: Text(widget.isEdit ? 'Save Changes' : 'Save Task'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _priorityButton(String value) {
    final selected = priority == value;

    return Expanded(
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            priority = value;
          });
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? const Color(0xFF2563EB) : Colors.white,
          foregroundColor: selected ? Colors.white : const Color(0xFF374151),
        ),
        child: Text(value),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),

        child: Text(
          formatDate(date),
          style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
        ),
      ),
    );
  }
}