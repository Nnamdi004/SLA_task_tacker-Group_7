import 'dart:async';
import 'package:flutter/material.dart';

import '../models/task.dart';
import '../state/task_store.dart';
import 'create_task_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'task_details_screen.dart';
import 'task_list_screen.dart';
import 'team_member.dart'; // TeamScreen, TeamMember, kTeamRoster

/// Holds the bottom navigation and connects every screen to the TaskStore.
class AppShell extends StatefulWidget {
  final TaskStore store;
  final int initialIndex;

  /// Email of the signed-in user (passed from Sign In).
  final String userEmail;

  const AppShell({
    super.key,
    required this.store,
    this.initialIndex = 0,
    this.userEmail = 'nnamdi@atlas.dev',
  });

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

  /// The roster member whose email matches the signed-in user.
  TeamMember get _currentUser => kTeamRoster.firstWhere(
        (m) => m.email.toLowerCase() == widget.userEmail.toLowerCase(),
        orElse: () => kTeamRoster.first,
      );

  void _goToTab(int i) => setState(() => _index = i);

  // The form validates, calls onSave with the new Task, then closes itself.
  void _createTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateTaskScreen(onSave: widget.store.add),
      ),
    );
  }

  void _openDetails(Task task) {
    final id = task.id;
    if (id == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailsScreen(store: widget.store, taskId: id),
      ),
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
      // One listener: whenever a task is added or changed, every tab rebuilds
      // with the new list.
      body: ListenableBuilder(
        listenable: widget.store,
        builder: (context, _) {
          final tasks = widget.store.tasks;
          final now = DateTime.now();
          return IndexedStack(
            index: _index,
            children: [
              DashboardScreen(
                userEmail: widget.userEmail,
                tasks: tasks,
                onCreateTask: _createTask,
                onViewAll: () => _goToTab(1),
                onTaskTap: _openDetails,
              ),
              TaskListScreen(
                tasks: tasks,
                now: now,
                onCreateTask: _createTask,
                onTaskTap: _openDetails,
                onFilterTap: _openFilters,
              ),
              TeamScreen(tasks: tasks),
              ProfileScreen(currentUser: _currentUser, tasks: tasks),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goToTab,
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