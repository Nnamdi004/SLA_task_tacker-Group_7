import 'package:flutter/material.dart';
import 'team_member.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  // The signed-in user, passed in from wherever Sign In/User Selection
  // lands once that screen exists. Defaults to the sample user for now
  // so this screen can be tested standalone.
  final TeamMember currentUser;

  const ProfileScreen({
    super.key,
    this.currentUser = const TeamMember(
      id: '1',
      name: 'Nnamdi Onugha',
      role: 'Team lead · Frontend',
      email: 'nnamdi@atlas.dev',
      assigned: 4,
      completed: 2,
      open: 2,
    ),
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Local copy of the user so Edit Profile can update the screen with setState.
  late TeamMember _user;

  @override
  void initState() {
    super.initState();
    _user = widget.currentUser;
  }

  // Opens the edit form and waits for the updated user to come back.
  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<TeamMember>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user)),
    );
    if (updated != null) {
      setState(() => _user = updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final progress = user.completionRate;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Your account and preferences',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // --- Identity card ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(radius: 24, child: Text(user.initials)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              user.role,
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              user.email,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _openEditProfile,
                      child: const Text('Edit Profile'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Workspace card ---
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workspace & project',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Atlas development team'),
                  Text('Atlas release project'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Task progress card ---
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My task progress',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(label: 'Assigned', value: user.assigned),
                      _StatColumn(label: 'Completed', value: user.completed),
                      _StatColumn(label: 'Open', value: user.open),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Account & settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _SettingsTile(icon: Icons.notifications_outlined, label: 'Notifications'),
          _SettingsTile(icon: Icons.shield_outlined, label: 'Password & security'),
          _SettingsTile(icon: Icons.help_outline, label: 'Help & support'),
          const SizedBox(height: 16),

          Center(
            child: TextButton.icon(
              onPressed: () {
                // Hook up to a sign-out flow once Sign In exists.
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Sign out', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final int value;

  const _StatColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SettingsTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}