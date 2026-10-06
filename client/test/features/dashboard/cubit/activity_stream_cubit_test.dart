import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/features/dashboard/cubit/activity_stream_cubit.dart';
import 'package:client/features/dashboard/cubit/activity_stream_state.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/data/models/activity_filter.dart';

class MockActivityRepository extends Mock implements ActivityRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(const ActivityFilter.empty());
  });

  group('ActivityStreamCubit', () {
    late MockActivityRepository mockRepo;

    final dummyActivities = [
      ActivityEventDto(
        id: 1,
        workspaceId: 10,
        actorId: 'u1',
        actorName: 'Alex',
        eventType: 'TaskCreated',
        metadata: const {'Title': 'Task One'},
        createdAt: DateTime(2026, 9, 22, 10),
      ),
      ActivityEventDto(
        id: 2,
        workspaceId: 10,
        actorId: 'u2',
        actorName: 'Sam',
        eventType: 'ProjectCreated',
        metadata: const {'Name': 'Project Alpha'},
        createdAt: DateTime(2026, 9, 22, 11),
      ),
    ];

    setUp(() {
      mockRepo = MockActivityRepository();
    });

    test('initial state has loading true', () {
      final cubit = ActivityStreamCubit(mockRepo);
      expect(cubit.state.isLoading, isTrue);
      expect(cubit.state.activities, isEmpty);
      expect(cubit.state.filteredActivities, isEmpty);
      cubit.close();
    });

    blocTest<ActivityStreamCubit, ActivityStreamState>(
      'loadActivities populates activities and applies default filter',
      build: () {
        when(
          () => mockRepo.getWorkspaceActivities(
            10,
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
          ),
        ).thenAnswer((_) async => dummyActivities);
        return ActivityStreamCubit(mockRepo);
      },
      act: (cubit) => cubit.loadActivities(10),
      expect: () => [
        isA<ActivityStreamState>().having(
          (s) => s.isLoading,
          'isLoading',
          isTrue,
        ),
        isA<ActivityStreamState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.activities.length, 'activities count', 2)
            .having((s) => s.filteredActivities.length, 'filtered count', 2)
            .having((s) => s.filteredActivities.first.id, 'newest first', 2)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
      verify: (_) {
        verify(
          () => mockRepo.getWorkspaceActivities(
            10,
            limit: 50,
            filter: any(named: 'filter'),
          ),
        ).called(1);
      },
    );

    blocTest<ActivityStreamCubit, ActivityStreamState>(
      'loadActivities handles failure cleanly',
      build: () {
        when(
          () => mockRepo.getWorkspaceActivities(
            10,
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
          ),
        ).thenThrow(Exception('Network error'));
        return ActivityStreamCubit(mockRepo);
      },
      act: (cubit) => cubit.loadActivities(10),
      expect: () => [
        isA<ActivityStreamState>().having(
          (s) => s.isLoading,
          'isLoading',
          isTrue,
        ),
        isA<ActivityStreamState>()
            .having((s) => s.isLoading, 'isLoading', isFalse)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<ActivityStreamCubit, ActivityStreamState>(
      'updateCategory filters activities immediately and queries repository',
      build: () {
        when(
          () => mockRepo.getWorkspaceActivities(
            10,
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
          ),
        ).thenAnswer((_) async => dummyActivities);
        return ActivityStreamCubit(mockRepo);
      },
      seed: () => ActivityStreamState(
        isLoading: false,
        activities: dummyActivities,
        filteredActivities: dummyActivities,
        filter: const ActivityFilter.empty(),
      ),
      act: (cubit) async {
        // Need workspaceId set
        cubit.loadActivities(10);
        await pumpEventQueue();
        cubit.updateCategory('Tasks');
      },
      skip: 2, // skip loadActivities loading and loaded
      expect: () => [
        // Immediate local filter
        isA<ActivityStreamState>()
            .having((s) => s.filteredActivities.length, 'filtered length', 1)
            .having(
              (s) => s.filteredActivities.first.eventType,
              'eventType',
              'TaskCreated',
            )
            .having((s) => s.filter.category, 'category', 'Tasks'),
        // Server response filter
        isA<ActivityStreamState>()
            .having((s) => s.filteredActivities.length, 'filtered length', 1)
            .having(
              (s) => s.filteredActivities.first.eventType,
              'eventType',
              'TaskCreated',
            ),
      ],
    );

    blocTest<ActivityStreamCubit, ActivityStreamState>(
      'clearFilters resets filter to empty and shows all activities',
      build: () {
        when(
          () => mockRepo.getWorkspaceActivities(
            10,
            limit: any(named: 'limit'),
            filter: any(named: 'filter'),
          ),
        ).thenAnswer((_) async => dummyActivities);
        return ActivityStreamCubit(mockRepo);
      },
      seed: () => ActivityStreamState(
        isLoading: false,
        activities: dummyActivities,
        filteredActivities: [dummyActivities.first],
        filter: const ActivityFilter.empty().copyWith(category: 'Tasks'),
      ),
      act: (cubit) async {
        cubit.loadActivities(10);
        await pumpEventQueue();
        cubit.clearFilters();
      },
      skip: 2, // skip loadActivities states
      expect: () => [
        isA<ActivityStreamState>()
            .having((s) => s.filter.category, 'category', 'All')
            .having((s) => s.filteredActivities.length, 'filtered length', 2),
        isA<ActivityStreamState>()
            .having((s) => s.filter.category, 'category', 'All')
            .having((s) => s.filteredActivities.length, 'filtered length', 2),
      ],
    );
  });
}
