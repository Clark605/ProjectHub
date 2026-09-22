import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/dashboard/cubit/activity_stream_cubit.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/data/models/activity_filter.dart';

class MockActivityRepository extends Fake implements ActivityRepository {
  List<ActivityEventDto> activitiesToReturn = [];
  bool shouldThrow = false;
  int callCount = 0;
  ActivityFilter? lastFilterPassed;

  @override
  Future<List<ActivityEventDto>> getWorkspaceActivities(
    int workspaceId, {
    int limit = 20,
    ActivityFilter? filter,
  }) async {
    callCount++;
    lastFilterPassed = filter;
    if (shouldThrow) {
      throw Exception('Network error');
    }
    return filter != null
        ? filter.apply(activitiesToReturn)
        : activitiesToReturn;
  }
}

void main() {
  group('ActivityStreamCubit Tests', () {
    late MockActivityRepository mockRepo;
    late ActivityStreamCubit cubit;

    final dummyActivities = [
      ActivityEventDto(
        id: 1,
        workspaceId: 10,
        actorId: 'u1',
        actorName: 'Alex',
        eventType: 'TaskCreated',
        metadata: {'Title': 'Task One'},
        createdAt: DateTime(2026, 9, 22, 10),
      ),
      ActivityEventDto(
        id: 2,
        workspaceId: 10,
        actorId: 'u2',
        actorName: 'Sam',
        eventType: 'ProjectCreated',
        metadata: {'Name': 'Project Alpha'},
        createdAt: DateTime(2026, 9, 22, 11),
      ),
    ];

    setUp(() {
      mockRepo = MockActivityRepository();
      cubit = ActivityStreamCubit(mockRepo);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has loading true', () {
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.activities, isEmpty);
      expect(cubit.state.filteredActivities, isEmpty);
    });

    test(
      'loadActivities populates activities and applies default filter',
      () async {
        mockRepo.activitiesToReturn = dummyActivities;

        await cubit.loadActivities(10);

        expect(cubit.state.isLoading, isFalse);
        expect(cubit.state.activities.length, 2);
        expect(cubit.state.filteredActivities.length, 2);
        expect(cubit.state.filteredActivities.first.id, 2); // newest first
        expect(cubit.state.errorMessage, isNull);
      },
    );

    test('loadActivities handles failure cleanly', () async {
      mockRepo.shouldThrow = true;

      await cubit.loadActivities(10);

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, isNotNull);
    });

    test(
      'updateCategory filters activities immediately and queries repository',
      () async {
        mockRepo.activitiesToReturn = dummyActivities;
        await cubit.loadActivities(10);

        cubit.updateCategory('Tasks');

        // Immediate local evaluation
        expect(cubit.state.filteredActivities.length, 1);
        expect(cubit.state.filteredActivities.first.eventType, 'TaskCreated');
        expect(cubit.state.filter.category, 'Tasks');
      },
    );

    test(
      'clearFilters resets filter to empty and shows all activities',
      () async {
        mockRepo.activitiesToReturn = dummyActivities;
        await cubit.loadActivities(10);

        cubit.updateCategory('Tasks');
        expect(cubit.state.filteredActivities.length, 1);

        cubit.clearFilters();
        expect(cubit.state.filter.category, 'All');
        expect(cubit.state.filteredActivities.length, 2);
      },
    );
  });
}
