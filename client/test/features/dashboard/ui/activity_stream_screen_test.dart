import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/data/models/activity_filter.dart';
import 'package:client/features/dashboard/ui/activity_stream_screen.dart';
import 'package:client/features/dashboard/ui/widgets/activity_tile.dart';

class MockActivityRepository extends Mock implements ActivityRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const ActivityFilter.empty());
  });

  late MockActivityRepository mockRepo;
  late List<ActivityEventDto> activities;

  setUp(() {
    mockRepo = MockActivityRepository();
    activities = [];

    when(
      () => mockRepo.getWorkspaceActivities(
        any(),
        limit: any(named: 'limit'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((inv) async {
      final filter = inv.namedArguments[#filter] as ActivityFilter?;
      return filter != null ? filter.apply(activities) : activities;
    });
  });

  testWidgets('ActivityStreamScreen renders activities list', (tester) async {
    activities = [
      ActivityEventDto.fromJson({
        'id': 1,
        'workspaceId': 10,
        'actorId': 'u1',
        'actorName': 'Alex',
        'eventType': 'TaskCreated',
        'metadata': {'Title': 'Build skeleton'},
        'createdAt': DateTime.now().toIso8601String(),
      }),
      ActivityEventDto.fromJson({
        'id': 2,
        'workspaceId': 10,
        'actorId': 'u2',
        'actorName': 'Sam',
        'eventType': 'ProjectCreated',
        'metadata': {'Name': 'Core'},
        'createdAt': DateTime.now().toIso8601String(),
      }),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ActivityStreamScreen(
          workspaceId: 10,
          activityRepository: mockRepo,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ActivityTile), findsNWidgets(2));
    final richTexts = tester.widgetList<RichText>(find.byType(RichText));
    final allPlainText = richTexts.map((r) => r.text.toPlainText()).join(' | ');
    expect(allPlainText, contains('Alex'));
    expect(allPlainText, contains('Sam'));
  });

  testWidgets('ActivityStreamScreen renders empty state when no activities', (
    tester,
  ) async {
    activities = [];

    await tester.pumpWidget(
      MaterialApp(
        home: ActivityStreamScreen(
          workspaceId: 10,
          activityRepository: mockRepo,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ActivityTile), findsNothing);
    expect(find.text('No recent activity yet'), findsOneWidget);
  });

  testWidgets(
    'ActivityStreamScreen renders error state and retries on button tap',
    (tester) async {
      int callCount = 0;
      when(
        () => mockRepo.getWorkspaceActivities(
          any(),
          limit: any(named: 'limit'),
          filter: any(named: 'filter'),
        ),
      ).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          throw Exception('Server unreachable');
        }
        return [
          ActivityEventDto.fromJson({
            'id': 1,
            'workspaceId': 10,
            'actorId': 'u1',
            'actorName': 'Alex',
            'eventType': 'TaskCreated',
            'metadata': {'Title': 'Done'},
            'createdAt': DateTime.now().toIso8601String(),
          }),
        ];
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityStreamScreen(
            workspaceId: 10,
            activityRepository: mockRepo,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
      expect(callCount, 1);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(callCount, 2);
      expect(find.byType(ActivityTile), findsOneWidget);
    },
  );

  testWidgets(
    'ActivityStreamScreen filters activities using quick filter chips',
    (tester) async {
      activities = [
        ActivityEventDto.fromJson({
          'id': 1,
          'workspaceId': 10,
          'actorId': 'u1',
          'actorName': 'Alex',
          'eventType': 'TaskCreated',
          'metadata': {'Title': 'Write tests'},
          'createdAt': DateTime.now().toIso8601String(),
        }),
        ActivityEventDto.fromJson({
          'id': 2,
          'workspaceId': 10,
          'actorId': 'u2',
          'actorName': 'Sam',
          'eventType': 'ProjectCreated',
          'metadata': {'Name': 'Platform'},
          'createdAt': DateTime.now().toIso8601String(),
        }),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityStreamScreen(
            workspaceId: 10,
            activityRepository: mockRepo,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ActivityTile), findsNWidgets(2));

      // Tap Tasks chip
      await tester.tap(find.byKey(const Key('activity_quick_filter_Tasks')));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityTile), findsOneWidget);
      var richTexts = tester.widgetList<RichText>(find.byType(RichText));
      var text = richTexts.map((r) => r.text.toPlainText()).join(' | ');
      expect(text, contains('Alex'));
      expect(text, isNot(contains('Sam')));

      // Tap Projects chip
      await tester.tap(find.byKey(const Key('activity_quick_filter_Projects')));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityTile), findsOneWidget);
      richTexts = tester.widgetList<RichText>(find.byType(RichText));
      text = richTexts.map((r) => r.text.toPlainText()).join(' | ');
      expect(text, contains('Sam'));
      expect(text, isNot(contains('Alex')));
    },
  );

  testWidgets(
    'ActivityStreamScreen shows filter empty state and resets filters',
    (tester) async {
      activities = [
        ActivityEventDto.fromJson({
          'id': 1,
          'workspaceId': 10,
          'actorId': 'u1',
          'actorName': 'Alex',
          'eventType': 'TaskCreated',
          'metadata': {'Title': 'Write tests'},
          'createdAt': DateTime.now().toIso8601String(),
        }),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityStreamScreen(
            workspaceId: 10,
            activityRepository: mockRepo,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ActivityTile), findsOneWidget);

      // Filter by Members (none exist)
      await tester.tap(find.byKey(const Key('activity_quick_filter_Members')));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityTile), findsNothing);
      expect(find.text('No activities match your filters'), findsOneWidget);
      expect(
        find.byKey(const Key('activity_stream_reset_filters_button')),
        findsOneWidget,
      );

      // Tap Reset Filters button
      await tester.tap(
        find.byKey(const Key('activity_stream_reset_filters_button')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ActivityTile), findsOneWidget);
    },
  );

  testWidgets('ActivityStreamScreen opens bottom sheet and applies search', (
    tester,
  ) async {
    activities = [
      ActivityEventDto.fromJson({
        'id': 1,
        'workspaceId': 10,
        'actorId': 'u1',
        'actorName': 'Alice Developer',
        'eventType': 'TaskCreated',
        'metadata': {'Title': 'Bugfix'},
        'createdAt': DateTime.now().toIso8601String(),
      }),
      ActivityEventDto.fromJson({
        'id': 2,
        'workspaceId': 10,
        'actorId': 'u2',
        'actorName': 'Bob Designer',
        'eventType': 'ProjectCreated',
        'metadata': {'Name': 'Style Guide'},
        'createdAt': DateTime.now().toIso8601String(),
      }),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ActivityStreamScreen(
          workspaceId: 10,
          activityRepository: mockRepo,
        ),
      ),
    );
    await tester.pump();

    // Tap filter button in AppBar
    await tester.tap(find.byKey(const Key('activity_stream_filter_button')));
    await tester.pumpAndSettle();

    expect(find.text('Filter & Sort'), findsOneWidget);

    // Enter search keyword
    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.pump();

    // Tap Apply Filters
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();

    expect(find.byType(ActivityTile), findsOneWidget);
    final richTexts = tester.widgetList<RichText>(find.byType(RichText));
    final text = richTexts.map((r) => r.text.toPlainText()).join(' | ');
    expect(text, contains('Alice'));
    expect(text, isNot(contains('Bob')));
  });
}
