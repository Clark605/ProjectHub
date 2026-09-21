import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/ui/widgets/activity_tile.dart';
import 'package:client/features/dashboard/ui/widgets/recent_activity_card.dart';

void main() {
  List<ActivityEventDto> generateActivities(int count) {
    return List.generate(count, (index) {
      return ActivityEventDto.fromJson({
        'id': index + 1,
        'workspaceId': 10,
        'actorId': 'user-$index',
        'actorName': 'User $index',
        'eventType': 'TaskCreated',
        'metadata': {'Title': 'Task $index', 'Status': 'Backlog'},
        'createdAt': DateTime.now()
            .subtract(Duration(minutes: index + 1))
            .toIso8601String(),
      });
    });
  }

  group('RecentActivityCard limits and View All', () {
    testWidgets('limits displayed activities to exactly 5 when 8 are provided', (
      tester,
    ) async {
      final activities = generateActivities(8);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecentActivityCard(
                activities: activities,
                workspaceId: 10,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(ActivityTile), findsNWidgets(5));
      expect(find.text('View all'), findsOneWidget);
    });

    testWidgets('calls onViewAll callback when View all button is tapped', (
      tester,
    ) async {
      bool tapped = false;
      final activities = generateActivities(3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecentActivityCard(
                activities: activities,
                onViewAll: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('View all'), findsOneWidget);
      await tester.tap(find.text('View all'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not show View all button when no workspaceId or onViewAll provided', (
      tester,
    ) async {
      final activities = generateActivities(3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecentActivityCard(activities: activities),
            ),
          ),
        ),
      );

      expect(find.text('View all'), findsNothing);
    });
  });
}
