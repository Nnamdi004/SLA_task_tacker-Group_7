import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/app_shell.dart';
import 'screens/sign_in_screen.dart';
import 'state/task_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final store = TaskStore(prefs)..load();

  runApp(SlaTaskTrackerApp(store: store));
}

class SlaTaskTrackerApp extends StatelessWidget {
  final TaskStore store;

  const SlaTaskTrackerApp({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLA Task Tracker',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2D5BE3),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),

      // Open the Dashboard when the app starts.
      home: AppShell(
        store: store,
        initialIndex: 0,
      ),

      routes: {
        // Sign-in screen
        '/signin': (context) => const SignInScreen(),

        // Dashboard tab
        '/dashboard': (context) => AppShell(
          store: store,
          initialIndex: 0,
        ),

        // Tasks tab
        '/tasks': (context) => AppShell(
          store: store,
          initialIndex: 1,
        ),
      },
    );
  }
}