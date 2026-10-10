import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/app_shell.dart';
import 'screens/sign_in_screen.dart';
import 'screens/dashboard_screen.dart';
import 'state/task_store.dart';
import 'screens/team_member.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';


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
      home: AppShell(
        store: store,
        initialIndex: 0,
      ),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/team': (context) => const TeamScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/tasks': (context) => AppShell(
              store: store,
              initialIndex: 1,
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final email = settings.arguments as String? ?? 'user@atlas.dev';
          return MaterialPageRoute(
            builder: (_) => DashboardScreen(userEmail: email),
          );
        }

        if (settings.name == '/edit-profile') {
          final user = settings.arguments is TeamMember
              ? settings.arguments as TeamMember
              : const TeamMember(
                  id: '1',
                  name: 'Nnamdi Onugha',
                  role: 'Team lead · Frontend',
                  email: 'nnamdi@atlas.dev',
                  assigned: 4,
                  completed: 2,
                  open: 2,
                );
          return MaterialPageRoute(
            builder: (_) => EditProfileScreen(user: user),
          );
        }

        return null;
      },
    );
  }
}