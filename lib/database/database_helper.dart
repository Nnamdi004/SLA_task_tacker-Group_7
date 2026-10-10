import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();

    final path = join(databasePath, 'task_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT,
            project TEXT NOT NULL,
            assignee TEXT NOT NULL,
            priority TEXT NOT NULL,
            startDate TEXT NOT NULL,
            deadline TEXT NOT NULL,
            status TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE
  Future<int> insertTask(Task task) async {
    final db = await database;

    return await db.insert('tasks', {
      'title': task.title,
      'description': task.description,
      'project': task.project,
      'assignee': task.assignee,
      'priority': task.priority,
      'startDate': task.startDate.toIso8601String(),
      'deadline': task.deadline.toIso8601String(),
      'status': task.status,
    });
  }

  // READ
  Future<List<Task>> getTasks() async {
    final db = await database;

    final result = await db.query('tasks', orderBy: 'id DESC');

    return result.map((map) {
      return Task(
        id: map['id'] as int,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        project: map['project'] as String,
        assignee: map['assignee'] as String,
        priority: map['priority'] as String,
        startDate: DateTime.parse(map['startDate'] as String),
        deadline: DateTime.parse(map['deadline'] as String),
        status: map['status'] as String,
      );
    }).toList();
  }

  // UPDATE
  Future<int> updateTask(Task task) async {
    final db = await database;

    return await db.update(
      'tasks',
      {
        'title': task.title,
        'description': task.description,
        'project': task.project,
        'assignee': task.assignee,
        'priority': task.priority,
        'startDate': task.startDate.toIso8601String(),
        'deadline': task.deadline.toIso8601String(),
        'status': task.status,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }
}
