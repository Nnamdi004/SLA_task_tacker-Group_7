import 'package:flutter/material.dart';
import 'team_member.dart';

// Colors taken from the Figma design.
const _bg = Color(0xFFF8FAFC);
const _border = Color(0xFFE2E8F0);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _blue = Color(0xFF2563EB);
const _green = Color(0xFF15803D);
const _navy = Color(0xFF172554);
const _paleBlue = Color(0xFFEEF2FF);

// Placeholder until the Tasks screen provides real SLA data.
const _overdueTasks = 1;

class TeamMember {
  final String id;
  final String name;
  final String role;
  final String email;
  final int assigned;
  final int completed;
  final int open;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.assigned,
    required this.completed,
    required this.open,
  });

  double get completionRate => assigned == 0 ? 0 : completed / assigned;

  String get initials => name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0])
      .take(2)
      .join()
      .toUpperCase();
}

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  // Sample data matching the Figma mock. Replace with data loaded from
  // SharedPreferences/sqflite once the group's storage layer is wired in.
  final List<TeamMember> _members = const [
    TeamMember(
      id: '1',
      name: 'Nnamdi Onugha',
      role: 'Team lead · Frontend',
      email: 'nnamdi@atlas.dev',
      assigned: 4,
      completed: 2,
      open: 2,
    ),
    TeamMember(
      id: '2',
      name: 'Liata Ornella',
      role: 'Backend developer',
      email: 'liata@atlas.dev',
      assigned: 3,
      completed: 2,
      open: 1,
    ),
    TeamMember(
      id: '3',
      name: 'Divine Mutesi',
      role: 'QA engineer',
      email: 'divine@atlas.dev',
      assigned: 3,
      completed: 1,
      open: 2,
    ),
    TeamMember(
      id: '4',
      name: 'Tumba II Kongolo',
      role: 'Mobile developer',
      email: 'tumba@atlas.dev',
      assigned: 2,
      completed: 1,
      open: 1,
    ),
  ];

  // Team-wide numbers are derived from the member data, not hardcoded.
  int get _totalCompleted => _members.fold(0, (sum, m) => sum + m.completed);
  int get _totalAssigned => _members.fold(0, (sum, m) => sum + m.assigned);
  int get _totalOpen => _members.fold(0, (sum, m) => sum + m.open);
  double get _teamProgress =>
      _totalAssigned == 0 ? 0 : _totalCompleted / _totalAssigned;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            // --- Header ---
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Team',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings_outlined, color: _ink),
                ),
              ],
            ),
            Text(
              'Atlas development · ${_members.length} members',
              style: const TextStyle(fontSize: 14, color: _muted),
            ),
            const SizedBox(height: 6),
            const Text(
              'SAMPLE SNAPSHOT · 03 OCT 2026, 10:00 UTC',
              style: TextStyle(fontSize: 11, color: _muted, letterSpacing: 0.4),
            ),
            const SizedBox(height: 16),

            // --- Team progress ---
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Team progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                      Text(
                        '${(_teamProgress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ProgressBar(value: _teamProgress),
                  const SizedBox(height: 10),
                  Text(
                    '$_totalCompleted of $_totalAssigned completed · '
                    '$_totalOpen open · $_overdueTasks overdue',
                    style: const TextStyle(fontSize: 13, color: _muted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Members ---
            const Text(
              'Team members',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(height: 12),
            ..._members.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MemberCard(member: m, highlighted: m.id == '1'),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Assigned counts include completed tasks in Atlas release.',
              style: TextStyle(fontSize: 12, color: _muted),
            ),
          ],
        ),
      ),
    );
  }
}

// White rounded card with a thin border and no shadow, as in the design.
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: child,
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  const _ProgressBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 5,
        color: _blue,
        backgroundColor: _border,
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final TeamMember member;
  final bool highlighted; // dark avatar, used for the current user

  const _MemberCard({required this.member, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final percent = (member.completionRate * 100).round();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: highlighted ? _navy : _paleBlue,
                ),
                child: Text(
                  member.initials,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: highlighted ? Colors.white : _blue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    Text(
                      member.role,
                      style: const TextStyle(fontSize: 13, color: _muted),
                    ),
                  ],
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            member.email,
            style: const TextStyle(fontSize: 13, color: _muted),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '${member.assigned} assigned',
                style: const TextStyle(fontSize: 13, color: _muted),
              ),
              const SizedBox(width: 16),
              Text(
                '${member.completed} completed',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _green,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${member.open} open',
                style: const TextStyle(fontSize: 13, color: _muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}