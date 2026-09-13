import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/ui/widgets/recent_activity_card.dart';

void main() {
  group('ActivityEventDto metadata parsing', () {
    test('parses json string metadata correctly', () {
      final json = {
        'id': 1,
        'workspaceId': 10,
        'actorId': 'user-1',
        'actorName': 'Google Test User',
        'eventType': 'TaskCreated',
        'metadata':
            '{"Title":"play haaha","Status":"Backlog","Priority":"Medium"}',
        'createdAt': '2026-09-13T00:00:00.000Z',
      };

      final dto = ActivityEventDto.fromJson(json);

      expect(dto.metadata, isNotNull);
      expect(dto.metadata!['Title'], 'play haaha');
      expect(dto.targetTitle, 'play haaha');
      expect(dto.status, 'Backlog');
    });

    test('parses map metadata correctly', () {
      final json = {
        'id': 2,
        'workspaceId': 10,
        'actorId': 'user-1',
        'actorName': 'Google Test User',
        'eventType': 'ProjectCreated',
        'metadata': {'Name': 'Project Alpha', 'Status': 'Planning'},
        'createdAt': '2026-09-13T00:00:00.000Z',
      };

      final dto = ActivityEventDto.fromJson(json);

      expect(dto.metadata, isNotNull);
      expect(dto.targetTitle, 'Project Alpha');
      expect(dto.status, 'Planning');
    });

    test('handles malformed or null metadata gracefully without throwing', () {
      final jsonMalformed = {
        'id': 3,
        'workspaceId': 10,
        'actorId': 'user-1',
        'actorName': 'Google Test User',
        'eventType': 'TaskCreated',
        'metadata': 'not a valid json string',
        'createdAt': '2026-09-13T00:00:00.000Z',
      };

      final dto = ActivityEventDto.fromJson(jsonMalformed);
      expect(dto.metadata, isNull);
      expect(dto.targetTitle, isNull);

      final jsonNull = {
        'id': 4,
        'workspaceId': 10,
        'actorId': 'user-1',
        'actorName': 'Google Test User',
        'eventType': 'WorkspaceCreated',
        'metadata': null,
        'createdAt': '2026-09-13T00:00:00.000Z',
      };

      final dtoNull = ActivityEventDto.fromJson(jsonNull);
      expect(dtoNull.metadata, isNull);
      expect(dtoNull.targetTitle, isNull);
    });
  });

  group('RecentActivityCard formatting', () {
    testWidgets('renders human-readable inline text without raw json string', (
      tester,
    ) async {
      final activities = [
        ActivityEventDto.fromJson({
          'id': 1,
          'workspaceId': 10,
          'actorId': 'u1',
          'actorName': 'Google Test User',
          'eventType': 'TaskCreated',
          'metadata':
              '{"Title":"play haaha","Status":"Backlog","Priority":"Medium"}',
          'createdAt': DateTime.now()
              .subtract(const Duration(minutes: 2))
              .toIso8601String(),
        }),
        ActivityEventDto.fromJson({
          'id': 2,
          'workspaceId': 10,
          'actorId': 'u1',
          'actorName': 'Google Test User',
          'eventType': 'ProjectCreated',
          'metadata': '{"Name":"hi","Status":"Planning"}',
          'createdAt': DateTime.now()
              .subtract(const Duration(minutes: 8))
              .toIso8601String(),
        }),
        ActivityEventDto.fromJson({
          'id': 3,
          'workspaceId': 10,
          'actorId': 'u1',
          'actorName': 'Google Test User',
          'eventType': 'TaskStatusChanged',
          'metadata':
              '{"Title":"play haaha","OldStatus":"Backlog","NewStatus":"Done"}',
          'createdAt': DateTime.now()
              .subtract(const Duration(minutes: 15))
              .toIso8601String(),
        }),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecentActivityCard(activities: activities),
            ),
          ),
        ),
      );

      // Verify that raw JSON strings are NOT present
      expect(find.textContaining('{"Title"'), findsNothing);
      expect(find.textContaining('{"Name"'), findsNothing);

      // Verify human-friendly titles are rendered in RichText spans
      expect(find.byType(RichText), findsWidgets);
      final richTexts = tester
          .widgetList<RichText>(find.byType(RichText))
          .toList();
      final allPlainText = richTexts
          .map((r) => r.text.toPlainText())
          .join(' | ');

      expect(
        allPlainText,
        contains('Google Test User created task "play haaha"'),
      );
      expect(allPlainText, contains('Google Test User created project "hi"'));
      expect(
        allPlainText,
        contains('Google Test User moved "play haaha" to Done'),
      );
    });
  });
}
