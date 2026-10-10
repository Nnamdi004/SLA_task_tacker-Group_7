import 'package:flutter/material.dart';

import 'screens/app_shell.dart';
import 'screens/sign_in_screen.dart';
import 'state/task_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load saved tasks from the sqflite database before the first screen shows.
  final store = TaskStore();
  await store.load();
  runApp(SlaTaskTrackerApp(store: store));
}

class SlaTaskTrackerApp extends StatelessWidget {
  final TaskStore store;
  const SlaTaskTrackerApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLA Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D5BE3)),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const SignInScreen(),
      routes: {
        '/signin': (context) => const SignInScreen(),
      },
      onGenerateRoute: (settings) {
        // Sign In navigates to '/dashboard' with the user's email as the
        // argument. Both routes open the shell (bottom nav + tabs).
        if (settings.name == '/dashboard' || settings.name == '/tasks') {
          final args = settings.arguments;
          final email = args is String ? args : 'nnamdi@atlas.dev';
          return MaterialPageRoute(
            builder: (_) => AppShell(
              store: store,
              userEmail: email,
              initialIndex: settings.name == '/tasks' ? 1 : 0,
            ),
          );
        }
        return null;
      },
    );
  }
}