import 'package:flutter/material.dart';

import 'models/task.dart';
import 'database/database_helper.dart';
import 'screens/create_task_screen.dart';
import 'screens/edit_task_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
        useMaterial3: true,
      ),
      home: const TaskHomeScreen(),
    );
  }
}

class TaskHomeScreen extends StatefulWidget {
  const TaskHomeScreen({super.key});

  @override
  State<TaskHomeScreen> createState() => _TaskHomeScreenState();
}

class _TaskHomeScreenState extends State<TaskHomeScreen> {
  List<Task> tasks = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final savedTasks = await DatabaseHelper.instance.getTasks();

    if (!mounted) return;

    setState(() {
      tasks = savedTasks;
      isLoading = false;
    });
  }

  Future<void> createTask(Task newTask) async {
    await DatabaseHelper.instance.insertTask(newTask);
    await loadTasks();
  }

  Future<void> updateTask(Task updatedTask) async {
    await DatabaseHelper.instance.updateTask(updatedTask);
    await loadTasks();
  }

  Future<void> openCreateTask() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(onSave: createTask),
      ),
    );

    await loadTasks();
  }

  Future<void> openEditTask(Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(task: task, onSave: updateTask),
      ),
    );

    await loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Task Manager',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tasks.isEmpty
          ? _emptyState()
          : _taskList(),

      floatingActionButton: FloatingActionButton(
        onPressed: openCreateTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.task_alt, size: 60, color: Color(0xFF9CA3AF)),

          const SizedBox(height: 20),

          const Text(
            'No tasks yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Create your first task to get started.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),

          const SizedBox(height: 25),

          ElevatedButton(
            onPressed: openCreateTask,
            child: const Text('Create Task'),
          ),
        ],
      ),
    );
  }

  Widget _taskList() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 15),

          child: ListTile(
            contentPadding: const EdgeInsets.all(15),

            title: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),

            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${task.project} • '
                '${task.priority} • '
                '${task.status}',
              ),
            ),

            trailing: IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                openEditTask(task);
              },
            ),
          ),
        );
      },
    );
  }
}
