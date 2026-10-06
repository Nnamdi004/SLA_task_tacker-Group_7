import 'package:flutter/material.dart';
import 'screens/sign_in_screen.dart';
import 'screens/dashboard_screen.dart';

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
        if (settings.name == '/dashboard') {
          final email = settings.arguments as String? ?? 'user@atlas.dev';
          return MaterialPageRoute(
            builder: (_) => DashboardScreen(userEmail: email),
          );
        }
        return null;
      },
    );
  }
}
