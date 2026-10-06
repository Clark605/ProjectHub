import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/kanban/ui/widgets/voice/voice_task_review_sheet.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/parsed_task_draft_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

void main() {
  group('VoiceTaskReviewSheet', () {
    testWidgets('renders pre-filled fields and warnings correctly', (tester) async {
      const draft = ParsedTaskDraftDto(
        title: 'Draft Task Title',
        description: 'Structured summary.\n\n- Point 1',
        priority: 'High',
        warnings: ['Could not determine due date'],
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: VoiceTaskReviewSheet(
              projectId: 1,
              draft: draft,
              onSubmit: (req, status) async {},
            ),
          ),
        ),
      );

      expect(find.text('AI Draft Preview'), findsOneWidget);
      expect(find.text('Draft Task Title'), findsOneWidget);
      expect(find.text('Structured summary.\n\n- Point 1'), findsOneWidget);
      expect(find.text('Could not determine due date'), findsOneWidget);
      expect(find.text('Confirm & Create Task'), findsOneWidget);
    });

    testWidgets('submits modified fields when user confirms', (tester) async {
      const draft = ParsedTaskDraftDto(
        title: 'Original Title',
        description: 'Original Description',
        priority: 'Low',
      );

      CreateTaskRequest? submittedRequest;
      String? submittedStatus;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: VoiceTaskReviewSheet(
              projectId: 1,
              draft: draft,
              onSubmit: (req, st) async {
                submittedRequest = req;
                submittedStatus = st;
              },
            ),
          ),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Original Title'),
        'Updated Task Title',
      );
      await tester.pump();

      await tester.tap(find.text('Confirm & Create Task'));
      await tester.pumpAndSettle();

      expect(submittedRequest?.title, 'Updated Task Title');
      expect(submittedStatus, 'Backlog');
    });
  });
}
