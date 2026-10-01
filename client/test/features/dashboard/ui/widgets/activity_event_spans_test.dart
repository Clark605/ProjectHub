import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/ui/widgets/activity_event_spans.dart';
import 'package:client/l10n/generated/app_localizations.dart';

void main() {
  group('ActivityEventSpans Tests', () {
    Widget buildTestHost(ActivityEventDto event, void Function(List<InlineSpan>) onSpans) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            final spans = buildActivityEventSpans(
              event,
              Theme.of(context),
              l10n,
            );
            onSpans(spans);
            return RichText(text: TextSpan(children: spans));
          },
        ),
      );
    }

    testWidgets('formats TaskCreated with project context and no quotes', (tester) async {
      final event = ActivityEventDto(
        id: 1,
        workspaceId: 10,
        projectId: 5,
        actorId: 'u1',
        actorName: 'Sarah',
        eventType: 'TaskCreated',
        metadata: {
          'Title': 'Design System',
          'ProjectName': 'ProjectHub Mobile',
        },
        createdAt: DateTime.now(),
      );

      List<InlineSpan> capturedSpans = [];
      await tester.pumpWidget(buildTestHost(event, (spans) => capturedSpans = spans));
      await tester.pumpAndSettle();

      final fullText = capturedSpans.map((s) => s.toPlainText()).join();
      expect(fullText, contains('created task Design System in ProjectHub Mobile'));
      expect(fullText, isNot(contains('"')));
    });

    testWidgets('formats TaskStatusChanged with project context and no quotes', (tester) async {
      final event = ActivityEventDto(
        id: 2,
        workspaceId: 10,
        projectId: 5,
        actorId: 'u1',
        actorName: 'Sarah',
        eventType: 'TaskStatusChanged',
        metadata: {
          'Title': 'Design System',
          'ProjectName': 'ProjectHub Mobile',
          'NewStatus': 'Done',
        },
        createdAt: DateTime.now(),
      );

      List<InlineSpan> capturedSpans = [];
      await tester.pumpWidget(buildTestHost(event, (spans) => capturedSpans = spans));
      await tester.pumpAndSettle();

      final fullText = capturedSpans.map((s) => s.toPlainText()).join();
      expect(fullText, contains('moved Design System to Done in ProjectHub Mobile'));
      expect(fullText, isNot(contains('"')));
    });

    testWidgets('formats ProjectDeleted with no quotes', (tester) async {
      final event = ActivityEventDto(
        id: 3,
        workspaceId: 10,
        actorId: 'u2',
        actorName: 'Alex',
        eventType: 'ProjectDeleted',
        metadata: {
          'ProjectName': 'Old Marketing Campaign',
        },
        createdAt: DateTime.now(),
      );

      List<InlineSpan> capturedSpans = [];
      await tester.pumpWidget(buildTestHost(event, (spans) => capturedSpans = spans));
      await tester.pumpAndSettle();

      final fullText = capturedSpans.map((s) => s.toPlainText()).join();
      expect(fullText, contains('deleted project Old Marketing Campaign'));
      expect(fullText, isNot(contains('"')));
    });
  });
}
