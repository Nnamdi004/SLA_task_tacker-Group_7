import 'package:flutter/material.dart';

import '../models/task.dart';
import '../widgets/task_form.dart';

class CreateTaskScreen extends StatelessWidget {
  final ValueChanged<Task> onSave;

  const CreateTaskScreen({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,

        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Color(0xFF374151),
          ),
        ),

        titleSpacing: 0,

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create task',
              style: TextStyle(
                color: Color(0xFF111827),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 2),

            Text(
              'Atlas release · unsaved draft',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
            ),
          ],
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close, size: 22, color: Color(0xFF374151)),
          ),
        ],
      ),

      body: TaskForm(onSave: onSave),
    );
  }
}
