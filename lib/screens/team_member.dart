import 'package:flutter/material.dart';

import '../models/task.dart';

// Colors taken from the Figma design.
const _bg = Color(0xFFF8FAFC);
const _border = Color(0xFFE2E8F0);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _blue = Color(0xFF2563EB);
const _green = Color(0xFF15803D);
const _navy = Color(0xFF172554);
const _paleBlue = Color(0xFFEEF2FF);

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

  /// Returns a copy whose assigned / completed / open counts are calculated
  /// from the real tasks. A task belongs to a member when the task's
  /// assignee name matches the member's name.
  TeamMember withTaskCounts(List<Task> tasks) {
    final mine = tasks.where(
      (t) => t.assignee.trim().toLowerCase() == name.trim().toLowerCase(),
    );
    final total = mine.length;
    final done = mine.where((t) => t.isCompleted).length;
    return TeamMember(
      id: id,
      name: name,
      role: role,
      email: email,
      assigned: total,
      completed: done,
      open: total - done,
    );
  }
}

/// The fixed team roster. The task counts here are placeholders; the screens
/// call [TeamMember.withTaskCounts] to get the real numbers.
const List<TeamMember> kTeamRoster = [
  TeamMember(
    id: '1',
    name: 'Nnamdi Onugha',
    role: 'Team lead · Frontend',
    email: 'nnamdi@atlas.dev',
    assigned: 0,
    completed: 0,
    open: 0,
  ),
  TeamMember(
    id: '2',
    name: 'Liata Ornella',
    role: 'Backend developer',
    email: 'liata@atlas.dev',
    assigned: 0,
    completed: 0,
    open: 0,
  ),
  TeamMember(
    id: '3',
    name: 'Divine Mutesi',
    role: 'QA engineer',
    email: 'divine@atlas.dev',
    assigned: 0,
    completed: 0,
    open: 0,
  ),
  TeamMember(
    id: '4',
    name: 'Tumba II Kongolo',
    role: 'Mobile developer',
    email: 'tumba@atlas.dev',
    assigned: 0,
    completed: 0,
    open: 0,
  ),
];

class TeamScreen extends StatelessWidget {
  /// All tasks from the TaskStore. Member counts and team progress are
  /// calculated from this list.
  final List<Task> tasks;

  const TeamScreen({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final members = kTeamRoster.map((m) => m.withTaskCounts(tasks)).toList();

    // Team-wide numbers come from the tasks themselves.
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final open = total - completed;
    final overdue = tasks.where((t) => t.sla(now) == SlaStatus.overdue).length;
    final progress = total == 0 ? 0.0 : completed / total;

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
              'Atlas development · ${members.length} members',
              style: const TextStyle(fontSize: 14, color: _muted),
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
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ProgressBar(value: progress),
                  const SizedBox(height: 10),
                  Text(
                    '$completed of $total completed · '
                    '$open open · $overdue overdue',
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
            ...members.map(
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