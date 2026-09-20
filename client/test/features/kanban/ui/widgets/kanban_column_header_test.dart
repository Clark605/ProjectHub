import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/kanban/ui/widgets/kanban_column_header.dart';
import 'package:client/features/tasks/data/models/task_status.dart';

void main() {
  Widget buildHeader(TaskStatus status, {int taskCount = 0}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 360,
            child: KanbanColumnHeader(
              status: status,
              taskCount: taskCount,
              isArchived: false,
              onAddTask: () {},
            ),
          ),
        ),
      ),
    );
  }

  group('KanbanColumnHeader', () {
    testWidgets('renders dot, title, task count badge, and add task button', (
      tester,
    ) async {
      await tester.pumpWidget(buildHeader(TaskStatus.todo, taskCount: 3));

      expect(find.text('To Do'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets(
      'add task button is aligned to the right consistently regardless of title length',
      (tester) async {
        // Measure right edge position for 'To Do' (short title)
        await tester.pumpWidget(buildHeader(TaskStatus.todo, taskCount: 1));
        final todoBtnRect = tester.getRect(find.byType(IconButton));

        // Measure right edge position for 'Backlog' (medium title)
        await tester.pumpWidget(buildHeader(TaskStatus.backlog, taskCount: 0));
        final backlogBtnRect = tester.getRect(find.byType(IconButton));

        // Measure right edge position for 'In Progress' (longer title)
        await tester.pumpWidget(
          buildHeader(TaskStatus.inProgress, taskCount: 0),
        );
        final inProgressBtnRect = tester.getRect(find.byType(IconButton));

        // All buttons should have the exact same right offset in a 360-wide container
        expect(todoBtnRect.right, equals(backlogBtnRect.right));
        expect(todoBtnRect.right, equals(inProgressBtnRect.right));
      },
    );
  });
}
