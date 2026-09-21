import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/ui/activity_stream_screen.dart';
import 'package:client/features/dashboard/ui/widgets/activity_tile.dart';

class FakeActivityRepository extends Fake implements ActivityRepository {
  List<ActivityEventDto> activitiesToReturn = [];
  bool shouldThrow = false;
  int callCount = 0;

  @override
  Future<List<ActivityEventDto>> getWorkspaceActivities(
    int workspaceId, {
    int limit = 20,
  }) async {
    callCount++;
    if (shouldThrow) {
      throw Exception('Server unreachable');
    }
    return activitiesToReturn;
  }
}

void main() {
  late FakeActivityRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeActivityRepository();
  });

  testWidgets('ActivityStreamScreen renders activities list', (tester) async {
    fakeRepo.activitiesToReturn = [
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
          activityRepository: fakeRepo,
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
    fakeRepo.activitiesToReturn = [];

    await tester.pumpWidget(
      MaterialApp(
        home: ActivityStreamScreen(
          workspaceId: 10,
          activityRepository: fakeRepo,
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
      fakeRepo.shouldThrow = true;

      await tester.pumpWidget(
        MaterialApp(
          home: ActivityStreamScreen(
            workspaceId: 10,
            activityRepository: fakeRepo,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
      expect(fakeRepo.callCount, 1);

      fakeRepo.shouldThrow = false;
      fakeRepo.activitiesToReturn = [
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

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(fakeRepo.callCount, 2);
      expect(find.byType(ActivityTile), findsOneWidget);
    },
  );
}
