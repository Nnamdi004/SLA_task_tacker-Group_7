import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/task.dart';

/// Single source of truth for tasks. Reads and writes go to the sqflite
/// database, and listeners (the screens) are notified after every change.
class TaskStore extends ChangeNotifier {
  TaskStore({DatabaseHelper? db}) : _db = db ?? DatabaseHelper.instance;

  final DatabaseHelper _db;
  List<Task> _tasks = [];

  /// Set when the last database call failed; null otherwise.
  String? lastError;

  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<void> load() async {
    try {
      _tasks = await _db.getTasks();
      lastError = null;
    } catch (e) {
      lastError = 'Could not load tasks: $e';
    }
    notifyListeners();
  }

  Future<void> add(Task task) async {
    try {
      await _db.insertTask(task);
    } catch (e) {
      lastError = 'Could not save task: $e';
    }
    await load();
  }

  Future<void> update(Task task) async {
    try {
      await _db.updateTask(task);
    } catch (e) {
      lastError = 'Could not update task: $e';
    }
    await load();
  }
}