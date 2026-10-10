import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task.dart';
import '../state/task_store.dart';
import 'edit_task_screen.dart';

const _bg = Color(0xFFF4F7FB);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);
const _blue = Color(0xFF1E88E5);

/// Shows one task, its SLA state, and lets the user edit it or mark it done.
///
/// It reads the task from the [TaskStore] by id, so the page updates by
/// itself after an edit or after the task is completed.
class TaskDetailsScreen extends StatelessWidget {
  final TaskStore store;
  final int taskId;

  const TaskDetailsScreen({
    super.key,
    required this.store,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final matches = store.tasks.where((t) => t.id == taskId);
        if (matches.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task details')),
            body: const Center(child: Text('This task no longer exists.')),
          );
        }

        final task = matches.first;
        final sla = task.sla(DateTime.now());
        final (slaFg, slaBg) = _slaColors(sla);

        return Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(
            backgroundColor: _bg,
            surfaceTintColor: _bg,
            elevation: 0,
            title: const Text(
              'Task details',
              style: TextStyle(fontWeight: FontWeight.w700, color: _ink),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Text(
                task.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Pill(label: task.status, fg: _blue, bg: const Color(0xFFE0EEFF)),
                  _Pill(label: sla.label, fg: slaFg, bg: slaBg),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                task.description.isEmpty
                    ? 'No description provided.'
                    : task.description,
                style: const TextStyle(fontSize: 14, color: _muted, height: 1.4),
              ),
              const SizedBox(height: 20),

              // --- Facts grid ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                ),
                child: Column(
                  children: [
                    Row(children: [
                      _Field(label: 'Project', value: task.project),
                      _Field(label: 'Assignee', value: task.assignee),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      _Field(label: 'Start date', value: _date(task.startDate)),
                      _Field(label: 'Deadline', value: _date(task.deadline)),
                    ]),
                    const SizedBox(height: 16),
                    Row(children: [
                      _Field(label: 'Priority', value: task.priority),
                      _Field(label: 'Task status', value: task.status),
                    ]),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- SLA message ---
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: slaBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.schedule_rounded, color: slaFg),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${sla.label}: ${_slaMessage(task, DateTime.now(), sla)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: slaFg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Actions ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _openEdit(context, task),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit task'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: task.isCompleted
                          ? null
                          : () => _confirmComplete(context, task, sla),
                      child: Text(
                        task.isCompleted ? 'Completed' : 'Mark as Completed',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ---- Actions ------------------------------------------------------------

  void _openEdit(BuildContext context, Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTaskScreen(task: task, onSave: store.update),
      ),
    );
  }

  Future<void> _confirmComplete(
    BuildContext context,
    Task task,
    SlaStatus sla,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete this task?'),
        content: Text(
          '"${task.title}" will be marked Completed. '
          'Its SLA will change from ${sla.label} to Completed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await store.update(task.copyWith(status: 'Completed'));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task marked as completed')),
    );
  }

  // ---- Helpers ------------------------------------------------------------

  String _date(DateTime d) => DateFormat('dd MMM yyyy').format(d);

  (Color, Color) _slaColors(SlaStatus s) => switch (s) {
        SlaStatus.onTrack => (_blue, const Color(0xFFE0EEFF)),
        SlaStatus.atRisk => (const Color(0xFFD97706), const Color(0xFFFEF3C7)),
        SlaStatus.overdue => (const Color(0xFFDC2626), const Color(0xFFFEE2E2)),
        SlaStatus.completed => (const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
      };

  String _slaMessage(Task task, DateTime now, SlaStatus sla) {
    switch (sla) {
      case SlaStatus.completed:
        return 'this task is finished.';
      case SlaStatus.overdue:
        return 'overdue by ${_span(now.difference(task.dueAt))}.';
      case SlaStatus.atRisk:
        return '${_span(task.dueAt.difference(now))} remaining. '
            'Incomplete and due within 24 hours.';
      case SlaStatus.onTrack:
        return '${_span(task.dueAt.difference(now))} remaining.';
    }
  }

  String _span(Duration d) {
    if (d.inDays >= 1) {
      return '${d.inDays} day${d.inDays == 1 ? '' : 's'}';
    }
    if (d.inHours >= 1) {
      return '${d.inHours} hour${d.inHours == 1 ? '' : 's'}';
    }
    return '${d.inMinutes < 1 ? 1 : d.inMinutes} min';
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: _muted)),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  const _Pill({required this.label, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}