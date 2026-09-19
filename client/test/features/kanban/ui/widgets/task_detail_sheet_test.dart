import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/tasks/ui/widgets/task_detail_sheet.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testTask = TaskDto(
    id: 10,
    projectId: 1,
    title: 'Test Task Detail',
    description: 'Detailed description',
    status: 'Todo',
    priority: 'High',
    assigneeId: 'unknown_user_99',
    assigneeName: 'Former Employee',
  );

  Widget createWidgetUnderTest({
    required TaskDto task,
    List<MemberDto> members = const [],
    Future<void> Function(UpdateTaskRequest)? onUpdate,
    Future<void> Function(String)? onStatusChange,
    Future<void> Function()? onDelete,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                TaskDetailSheet.show(
                  context,
                  task: task,
                  members: members,
                  onUpdate: onUpdate ?? (_) async {},
                  onStatusChange: onStatusChange ?? (_) async {},
                  onDelete: onDelete ?? () async {},
                );
              },
              child: const Text('Open Sheet'),
            );
          },
        ),
      ),
    );
  }

  testWidgets(
    'TaskDetailSheet opens in edit mode without crashing when assigneeId is not in members',
    (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          task: testTask,
          members: [
            MemberDto(
              userId: 'active_user_1',
              name: 'Active Member',
              email: 'active@example.com',
              role: 'Member',
              joinedAt: DateTime(2026, 1, 1),
            ),
          ],
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Test Task Detail'), findsOneWidget);
      expect(find.text('Former Employee'), findsOneWidget);

      // Tap Edit button
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // Ensure edit mode opened without assertion failure
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    },
  );

  testWidgets(
    'TaskDetailSheet saves changes and clears assigneeName when unassigning',
    (tester) async {
      UpdateTaskRequest? capturedRequest;

      await tester.pumpWidget(
        createWidgetUnderTest(
          task: testTask,
          members: [
            MemberDto(
              userId: 'unknown_user_99',
              name: 'Former Employee',
              email: 'former@example.com',
              role: 'Member',
              joinedAt: DateTime(2026, 1, 1),
            ),
          ],
          onUpdate: (req) async {
            capturedRequest = req;
          },
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Enter edit mode
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      // Select Unassigned from dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String?>));
      await tester.pumpAndSettle();

      // Tap the "Unassigned" option in the popup menu
      await tester.tap(find.text('Unassigned').last);
      await tester.pumpAndSettle();

      // Tap Save Changes
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(capturedRequest, isNotNull);
      expect(capturedRequest!.assigneeId, isNull);

      // Verify read mode displays Unassigned rather than Former Employee
      expect(find.text('Unassigned'), findsOneWidget);
    },
  );
}
