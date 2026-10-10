import 'package:flutter/material.dart';

import '../models/task.dart';

// ---------------------------------------------------------------------------
// Design tokens (approximated from the Figma screens)
// ---------------------------------------------------------------------------

class _C {
  static const bg = Color(0xFFF4F7FB);
  static const card = Colors.white;
  static const primary = Color(0xFF1E88E5);
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const chipBg = Color(0xFFFFFFFF);

  static const red = Color(0xFFDC2626);
  static const redBg = Color(0xFFFEE2E2);
  static const amber = Color(0xFFD97706);
  static const amberBg = Color(0xFFFEF3C7);
  static const green = Color(0xFF16A34A);
  static const greenBg = Color(0xFFDCFCE7);
  static const blueBg = Color(0xFFE0EEFF);
  static const grayBg = Color(0xFFEEF2F6);
}

// ---------------------------------------------------------------------------
// Task List screen
// The bottom navigation bar lives in AppShell (app_shell.dart), not here.
// The Task model and SLA rules live in models/task.dart.
// ---------------------------------------------------------------------------

enum _Filter { all, todo, inProgress, completed, overdue }

class TaskListScreen extends StatefulWidget {
  /// Pass `DateTime.now()` from the shell so SLA labels use the real time.
  final DateTime now;
  final List<Task> tasks;
  final String projectName;
  final VoidCallback? onCreateTask;
  final ValueChanged<Task>? onTaskTap;
  final VoidCallback? onFilterTap;

  const TaskListScreen({
    super.key,
    required this.tasks,
    required this.now,
    this.projectName = 'Atlas release',
    this.onCreateTask,
    this.onTaskTap,
    this.onFilterTap,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _searchCtrl = TextEditingController();
  _Filter _filter = _Filter.all;
  bool _recentFirst = true;
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Search -> filter -> sort. Newest = highest database id.
  List<Task> get _visible {
    final q = _query.trim().toLowerCase();
    final list = widget.tasks.where((t) {
      final matchesQuery = q.isEmpty ||
          t.title.toLowerCase().contains(q) ||
          t.assignee.toLowerCase().contains(q);
      if (!matchesQuery) return false;
      switch (_filter) {
        case _Filter.all:
          return true;
        case _Filter.todo:
          return t.status == 'To Do';
        case _Filter.inProgress:
          return t.status == 'In Progress';
        case _Filter.completed:
          return t.status == 'Completed';
        case _Filter.overdue:
          return t.sla(widget.now) == SlaStatus.overdue;
      }
    }).toList();

    list.sort((a, b) => _recentFirst
        ? (b.id ?? 0).compareTo(a.id ?? 0)
        : (a.id ?? 0).compareTo(b.id ?? 0));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _visible;
    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(tasks.length),
            Expanded(
              child: tasks.isEmpty
                  ? _buildEmpty()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      itemCount: tasks.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _TaskCard(
                        task: tasks[i],
                        now: widget.now,
                        onTap: () => widget.onTaskTap?.call(tasks[i]),
                      ),
                    ),
            ),
            _buildCreateButton(),
          ],
        ),
      ),
    );
  }

  // ---- Header ------------------------------------------------------------

  Widget _buildHeader(int shownCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tasks',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _C.text)),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.projectName} · ${widget.tasks.length} tasks',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _C.muted),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Filter',
                onPressed: widget.onFilterTap,
                icon: const Icon(Icons.tune_rounded, color: _C.text),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSearch(),
          const SizedBox(height: 12),
          _buildFilterChips(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$shownCount tasks',
                style: const TextStyle(fontSize: 12, color: _C.muted),
              ),
              InkWell(
                onTap: () => setState(() => _recentFirst = !_recentFirst),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Row(
                    children: [
                      Text(
                        _recentFirst ? 'Recent first' : 'Oldest first',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _C.muted),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        _recentFirst
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        size: 14,
                        color: _C.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return TextField(
      controller: _searchCtrl,
      onChanged: (v) => setState(() => _query = v),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search tasks or assignees',
        hintStyle: const TextStyle(color: _C.muted, fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: _C.text),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                },
              ),
        filled: true,
        fillColor: _C.card,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _C.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    const labels = {
      _Filter.all: 'All',
      _Filter.todo: 'To Do',
      _Filter.inProgress: 'In Progress',
      _Filter.completed: 'Completed',
      _Filter.overdue: 'Overdue',
    };
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = labels.keys.elementAt(i);
          final selected = f == _filter;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? _C.primary : _C.chipBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? _C.primary : _C.border),
              ),
              child: Text(
                labels[f]!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _C.text,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---- Empty state -------------------------------------------------------

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: _C.muted),
          SizedBox(height: 8),
          Text('No tasks match your filters',
              style: TextStyle(color: _C.muted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---- Footer ------------------------------------------------------------

  Widget _buildCreateButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: widget.onCreateTask,
          icon: const Icon(Icons.add_rounded, size: 22),
          label: const Text('Create task',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _C.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Task card
// ---------------------------------------------------------------------------

class _TaskCard extends StatelessWidget {
  final Task task;
  final DateTime now;
  final VoidCallback? onTap;

  const _TaskCard({required this.task, required this.now, this.onTap});

  @override
  Widget build(BuildContext context) {
    final sla = task.sla(now);
    return Material(
      color: _C.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _C.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _C.text)),
                  ),
                  const SizedBox(width: 8),
                  _PriorityLabel(priority: task.priority),
                ],
              ),
              const SizedBox(height: 6),
              Text(task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: _C.muted)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Avatar(name: task.assignee),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(task.assignee,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _C.muted)),
                  ),
                  const Icon(Icons.schedule_rounded, size: 15, color: _C.muted),
                  const SizedBox(width: 4),
                  Text(_formatDeadline(task.deadline),
                      style: const TextStyle(fontSize: 12, color: _C.muted)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Pill(
                    label: task.status,
                    fg: _statusFg(task.status),
                    bg: _statusBg(task.status),
                  ),
                  const SizedBox(width: 8),
                  _Pill(
                    label: sla.label,
                    fg: _slaFg(sla),
                    bg: _slaBg(sla),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- helpers ----

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String _formatDeadline(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    return '$dd ${_months[d.month - 1]} ${d.year}';
  }

  Color _statusFg(String s) => switch (s) {
        'In Progress' => _C.primary,
        'Completed' => _C.green,
        _ => _C.muted,
      };

  Color _statusBg(String s) => switch (s) {
        'In Progress' => _C.blueBg,
        'Completed' => _C.greenBg,
        _ => _C.grayBg,
      };

  Color _slaFg(SlaStatus s) => switch (s) {
        SlaStatus.onTrack => _C.primary,
        SlaStatus.atRisk => _C.amber,
        SlaStatus.overdue => _C.red,
        SlaStatus.completed => _C.green,
      };

  Color _slaBg(SlaStatus s) => switch (s) {
        SlaStatus.onTrack => _C.blueBg,
        SlaStatus.atRisk => _C.amberBg,
        SlaStatus.overdue => _C.redBg,
        SlaStatus.completed => _C.greenBg,
      };
}

class _PriorityLabel extends StatelessWidget {
  final String priority; // 'Low' | 'Medium' | 'High'
  const _PriorityLabel({required this.priority});

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (priority) {
      'High' => (_C.red, _C.redBg),
      'Medium' => (_C.amber, _C.amberBg),
      _ => (_C.green, _C.greenBg),
    };
    return _Pill(label: priority, fg: fg, bg: bg, small: true);
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color fg;
  final Color bg;
  final bool small;

  const _Pill({
    required this.label,
    required this.fg,
    required this.bg,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(label,
          style: TextStyle(
              fontSize: small ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: fg)),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 13,
      backgroundColor: _C.blueBg,
      child: Text(_initials,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w800, color: _C.primary)),
    );
  }
}