import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/core/widgets/app_error_banner.dart';
import 'package:client/features/kanban/ui/widgets/create_task_sheet.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidgetUnderTest({
    required Future<void> Function(CreateTaskRequest, String) onSubmit,
    List<MemberDto> members = const [],
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () {
                CreateTaskSheet.show(
                  context,
                  projectId: 42,
                  initialStatus: 'Backlog',
                  members: members,
                  onSubmit: onSubmit,
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
    'CreateTaskSheet renders form fields and closes on successful creation',
    (tester) async {
      CreateTaskRequest? submittedRequest;
      String? submittedStatus;

      await tester.pumpWidget(
        createWidgetUnderTest(
          onSubmit: (req, status) async {
            submittedRequest = req;
            submittedStatus = status;
          },
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateTaskSheet), findsOneWidget);
      expect(find.text('Task Title'), findsOneWidget);

      // Enter task title
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Task Title'),
        'Brand New Task',
      );
      await tester.pump();

      // Tap Create Task button
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      expect(submittedRequest, isNotNull);
      expect(submittedRequest!.title, 'Brand New Task');
      expect(submittedStatus, 'Backlog');

      // Sheet should be popped and closed
      expect(find.byType(CreateTaskSheet), findsNothing);
    },
  );

  testWidgets(
    'CreateTaskSheet stays open, retains inputs, and displays AppErrorBanner on submission failure (H1)',
    (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          onSubmit: (req, status) async {
            throw const AppException(message: 'Server rejected task title');
          },
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Enter title and description
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Task Title'),
        'Unsaved Feature',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description'),
        'Important context to preserve',
      );
      await tester.pump();

      // Tap submit
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      // Sheet must REMAIN open (H1)
      expect(find.byType(CreateTaskSheet), findsOneWidget);

      // Form fields must preserve user inputs
      expect(find.text('Unsaved Feature'), findsOneWidget);
      expect(find.text('Important context to preserve'), findsOneWidget);

      // AppErrorBanner must be visible with error message
      expect(find.byType(AppErrorBanner), findsOneWidget);
      expect(find.text('Server rejected task title'), findsOneWidget);

      // Dismiss the error banner
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Server rejected task title'), findsNothing);
      expect(find.text('Unsaved Feature'), findsOneWidget);
    },
  );
}
