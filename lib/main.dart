import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';

void main() {
  runApp(const SlaTaskTrackerApp());
}

class SlaTaskTrackerApp extends StatelessWidget {
  const SlaTaskTrackerApp({super.key});

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
        // Placeholder routes — other screens will be added by teammates
        if (settings.name == '/dashboard') {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Dashboard')),
              body: const Center(child: Text('Dashboard — coming soon')),
            ),
          );
        }
        return null;
      },
    );
  }
}
