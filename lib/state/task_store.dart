import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/task_list_screen.dart'; // for Task

class TaskStore extends ChangeNotifier {
  TaskStore(this._prefs);

  static const _key = 'tasks_v1';
  final SharedPreferences _prefs;
  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  void load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return;
    try {
      _tasks
        ..clear()
        ..addAll((jsonDecode(raw) as List)
            .map((e) => Task.fromJson(e as Map<String, dynamic>)));
    } catch (_) {
      // Corrupt data: start empty rather than crash.
      _tasks.clear();
    }
  }

  Future<void> add(Task task) async {
    _tasks.add(task);
    notifyListeners();
    await _save();
  }

  Future<void> update(Task task) async {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i == -1) return;
    _tasks[i] = task;
    notifyListeners();
    await _save();
  }

  Future<void> _save() => _prefs.setString(
      _key, jsonEncode(_tasks.map((t) => t.toJson()).toList()));
}