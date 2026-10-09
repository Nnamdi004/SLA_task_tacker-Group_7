import 'dart:async';
import 'package:flutter/material.dart';

import '../state/task_store.dart';
import 'task_list_screen.dart';

class AppShell extends StatefulWidget {
  final TaskStore store;
  final int initialIndex;
  const AppShell({super.key, required this.store, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    // Re-evaluate SLA labels every minute while the app is open.
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _createTask() async {
    final created = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const _CreateTaskStub()),
    );
    if (created != null) await widget.store.add(created);
  }

  void _openDetails(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _TaskDetailsStub(task: task)),
    );
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      builder: (_) => const SizedBox(
        height: 200,
        child: Center(child: Text('Filter options coming soon')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          // TODO(teammate): replace with DashboardScreen
          const Center(child: Text('Dashboard — coming soon')),

          // Task List (this screen)
          ListenableBuilder(
            listenable: widget.store,
            builder: (_, _) => TaskListScreen(
              tasks: widget.store.tasks,
              now: DateTime.now(),
              onCreateTask: _createTask,
              onTaskTap: _openDetails,
              onFilterTap: _openFilters,
            ),
          ),

          // TODO(teammate): replace with TeamScreen
          const Center(child: Text('Team — coming soon')),

          // TODO(teammate): replace with ProfileScreen
          const Center(child: Text('Profile — coming soon')),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.grid_view_rounded), label: 'Dashboard'),
          NavigationDestination(
              icon: Icon(Icons.checklist_rounded), label: 'Tasks'),
          NavigationDestination(
              icon: Icon(Icons.groups_outlined), label: 'Team'),
          NavigationDestination(
              icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Temporary stubs so the Task List flow works end to end.
// Delete these when the real Task Details and Create/Edit screens are merged.
// ---------------------------------------------------------------------------

class _TaskDetailsStub extends StatelessWidget {
  final Task task;
  const _TaskDetailsStub({required this.task});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Task details')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(task.title, style: const TextStyle(fontSize: 22)),
        ),
      );
}

class _CreateTaskStub extends StatefulWidget {
  const _CreateTaskStub();

  @override
  State<_CreateTaskStub> createState() => _CreateTaskStubState();
}

class _CreateTaskStubState extends State<_CreateTaskStub> {
  final _title = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    Navigator.pop(
      context,
      Task(
        id: now.microsecondsSinceEpoch.toString(),
        title: _title.text.trim(),
        description: 'Added from the stub form.',
        assignee: 'Nnamdi Onugha',
        priority: Priority.medium,
        status: TaskStatus.todo,
        deadline: now.add(const Duration(hours: 12)),
        createdAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Create task')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title *'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'A task title is required.'
                      : null,
                ),
                const SizedBox(height: 20),
                FilledButton(onPressed: _save, child: const Text('Save task')),
              ],
            ),
          ),
        ),
      );
}