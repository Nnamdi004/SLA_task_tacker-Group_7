import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sla_task_tracker/models/task.dart';
import 'package:sla_task_tracker/screens/task_list_screen.dart';

Task makeTask({
  required int id,
  required String title,
  required String assignee,
  required String status,
  required DateTime deadline,
  String priority = 'Medium',
}) {
  return Task(
    id: id,
    title: title,
    description: 'Description for $title',
    project: 'Atlas release',
    assignee: assignee,
    priority: priority,
    startDate: DateTime(2026, 10, 1),
    deadline: deadline,
    status: status,
  );
}

void main() {
  // Fixed "now" so the SLA results are deterministic.
  final now = DateTime(2026, 10, 3, 10, 0);

  final atRisk = makeTask(
    id: 1,
    title: 'API authentication',
    assignee: 'Liata Ornella',
    status: 'In Progress',
    deadline: DateTime(2026, 10, 3), // due end of today -> At Risk
    priority: 'High',
  );
  final overdue = makeTask(
    id: 2,
    title: 'Regression test suite',
    assignee: 'Divine Mutesi',
    status: 'To Do',
    deadline: DateTime(2026, 10, 2), // yesterday -> Overdue
    priority: 'High',
  );
  final onTrack = makeTask(
    id: 3,
    title: 'Dashboard analytics',
    assignee: 'Nnamdi Onugha',
    status: 'In Progress',
    deadline: DateTime(2026, 10, 8), // days away -> On Track
  );
  final tasks = [atRisk, overdue, onTrack];

  Future<void> pumpScreen(WidgetTester tester) async {
    // Wide phone-sized surface so every filter chip and card is built.
    tester.view.physicalSize = const Size(1500, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: TaskListScreen(tasks: tasks, now: now),
    ));
  }

  group('SLA rules', () {
    test('classifies tasks correctly', () {
      expect(atRisk.sla(now), SlaStatus.atRisk);
      expect(overdue.sla(now), SlaStatus.overdue);
      expect(onTrack.sla(now), SlaStatus.onTrack);
    });

    test('completed wins even when the deadline has passed', () {
      final done = makeTask(
        id: 4,
        title: 'Done',
        assignee: 'Tumba II Kongolo',
        status: 'Completed',
        deadline: DateTime(2026, 10, 1),
      );
      expect(done.sla(now), SlaStatus.completed);
    });

    test('a task is due at the end of its deadline day', () {
      final t = makeTask(
        id: 5,
        title: 'Late today',
        assignee: 'Nnamdi Onugha',
        status: 'To Do',
        deadline: DateTime(2026, 10, 3),
      );
      expect(t.sla(DateTime(2026, 10, 3, 23, 59)), SlaStatus.atRisk);
      expect(t.sla(DateTime(2026, 10, 4, 0, 0, 1)), SlaStatus.overdue);
    });

    test('exactly 24 hours before the due time is At Risk', () {
      final t = makeTask(
        id: 6,
        title: 'Boundary',
        assignee: 'Nnamdi Onugha',
        status: 'To Do',
        deadline: DateTime(2026, 10, 4), // due 4 Oct 23:59:59
      );
      expect(t.sla(DateTime(2026, 10, 3, 23, 59, 59)), SlaStatus.atRisk);
      expect(t.sla(DateTime(2026, 10, 3, 23, 59, 58)), SlaStatus.onTrack);
    });

    test('labels', () {
      expect(SlaStatus.atRisk.label, 'At Risk');
      expect(SlaStatus.onTrack.label, 'On Track');
    });
  });

  group('TaskListScreen', () {
    testWidgets('shows header and all tasks', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('API authentication'), findsOneWidget);
      expect(find.text('Regression test suite'), findsOneWidget);
      expect(find.text('Dashboard analytics'), findsOneWidget);
      expect(find.text('At Risk'), findsOneWidget);
      expect(find.text('On Track'), findsOneWidget);
    });

    testWidgets('Overdue filter shows only overdue tasks', (tester) async {
      await pumpScreen(tester);

      // The chip is above the cards, so .first is the chip.
      await tester.tap(find.text('Overdue').first);
      await tester.pump();

      expect(find.text('Regression test suite'), findsOneWidget);
      expect(find.text('API authentication'), findsNothing);
      expect(find.text('Dashboard analytics'), findsNothing);
    });

    testWidgets('search filters by title', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField), 'dashboard');
      await tester.pump();

      expect(find.text('Dashboard analytics'), findsOneWidget);
      expect(find.text('API authentication'), findsNothing);
    });

    testWidgets('shows empty state when nothing matches', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump();

      expect(find.text('No tasks match your filters'), findsOneWidget);
    });
  });
}