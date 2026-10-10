import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  final String userEmail;

  /// Called by the "+ Create task" button. AppShell opens the Create screen.
  final VoidCallback? onCreateTask;

  /// Called by "View all →". AppShell switches to the Tasks tab.
  final VoidCallback? onViewAll;

  const DashboardScreen({
    super.key,
    required this.userEmail,
    this.onCreateTask,
    this.onViewAll,
  });

  String get _userName {
    final name = userEmail.split('@').first;
    return name[0].toUpperCase() + name.substring(1);
  }

  String get _initials {
    final username = userEmail.split('@').first.toLowerCase();
    if (username.startsWith('nnamdi')) return 'NO';
    if (username.startsWith('admin')) return 'AD';
    final letters = username.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    return letters.length >= 2 ? letters.substring(0, 2).toUpperCase() : letters.toUpperCase();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  // Strip trailing digits from display name e.g. Nnamdi004 → Nnamdi
  String get _displayName {
    return _userName.replaceAll(RegExp(r'\d+$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM').format(now);
    final snapshotStr = DateFormat('dd MMM yyyy, HH:mm').format(now).toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(fontSize: 12, color: Colors.black45),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$_greeting, $_displayName 👋',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'SAMPLE SNAPSHOT · $snapshotStr UTC',
                              style: const TextStyle(fontSize: 10, color: Colors.black38),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFF1A1A2E),
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stat cards
                    Row(
                      children: [
                        _StatCard(
                          label: 'Total Tasks',
                          value: '12',
                          icon: Icons.layers_outlined,
                          iconColor: const Color(0xFF2D5BE3),
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Completed',
                          value: '6',
                          icon: Icons.check_circle_outline,
                          iconColor: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatCard(
                          label: 'In Progress',
                          value: '4',
                          icon: Icons.autorenew,
                          iconColor: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _StatCard(
                          label: 'Overdue',
                          value: '1',
                          icon: Icons.alarm,
                          iconColor: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Project progress
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Atlas release',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              Text(
                                '50%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF2D5BE3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: 0.5,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE8ECFF),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D5BE3)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '6 of 12 tasks completed · 2 still to do',
                            style: TextStyle(fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // SLA Overview
                    const Text(
                      'SLA overview',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _SlaChip(count: '6', label: 'Completed', color: Colors.green),
                        const SizedBox(width: 8),
                        _SlaChip(count: '1', label: 'Overdue', color: Colors.red),
                        const SizedBox(width: 8),
                        _SlaChip(count: '2', label: 'At Risk', color: const Color(0xFFB8860B)),
                        const SizedBox(width: 8),
                        _SlaChip(count: '3', label: 'On Track', color: Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Recent tasks header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent tasks',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        TextButton(
                          onPressed: onViewAll,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'View all →',
                            style: TextStyle(color: Color(0xFF2D5BE3), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Task cards
                    _TaskCard(
                      title: 'API authentication',
                      priority: 'High',
                      assigneeInitials: 'LO',
                      assigneeName: 'Liata Ornela',
                      dueDate: '03 Oct, 18:00',
                      status: 'In Progress',
                      slaStatus: 'At Risk',
                    ),
                    const SizedBox(height: 10),
                    _TaskCard(
                      title: 'Regression test suite',
                      priority: 'High',
                      assigneeInitials: 'DM',
                      assigneeName: 'Divine Mutesi',
                      dueDate: '02 Oct, 17:00',
                      status: 'To Do',
                      slaStatus: 'Overdue',
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FloatingActionButton.extended(
            onPressed: onCreateTask,
            backgroundColor: const Color(0xFF2D5BE3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            label: const Text(
              '+ Create task',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // The bottom navigation bar now lives in AppShell (app_shell.dart).
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.black45)),
                Icon(icon, size: 18, color: iconColor),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlaChip extends StatelessWidget {
  final String count;
  final String label;
  final Color color;

  const _SlaChip({required this.count, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String priority;
  final String assigneeInitials;
  final String assigneeName;
  final String dueDate;
  final String status;
  final String slaStatus;

  const _TaskCard({
    required this.title,
    required this.priority,
    required this.assigneeInitials,
    required this.assigneeName,
    required this.dueDate,
    required this.status,
    required this.slaStatus,
  });

  Color get _slaColor {
    switch (slaStatus) {
      case 'Overdue': return Colors.red;
      case 'At Risk': return const Color(0xFFB8860B);
      case 'On Track': return Colors.blue;
      case 'Completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  Color get _statusColor {
    switch (status) {
      case 'In Progress': return Colors.blue;
      case 'To Do': return Colors.grey;
      case 'Done': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  priority,
                  style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: const Color(0xFF2D5BE3),
                child: Text(
                  assigneeInitials,
                  style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 6),
              Text(assigneeName, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const Spacer(),
              const Icon(Icons.access_time, size: 12, color: Colors.black38),
              const SizedBox(width: 3),
              Text(dueDate, style: const TextStyle(fontSize: 11, color: Colors.black45)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _Chip(label: status, color: _statusColor),
              const SizedBox(width: 6),
              _Chip(label: slaStatus, color: _slaColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}