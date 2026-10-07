import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/tasks/cubit/my_tasks_cubit.dart';
import 'package:client/features/tasks/cubit/my_tasks_state.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      const UpdateTaskRequest(title: 'Fallback', priority: 'Medium'),
    );
  });

  group('MyTasksCubit', () {
    late MockTaskRepository repo;

    setUp(() {
      repo = MockTaskRepository();
    });

    test('initial state is MyTasksState.initial()', () {
      final cubit = MyTasksCubit(repo);
      expect(cubit.state, const MyTasksState.initial());
      cubit.close();
    });

    blocTest<MyTasksCubit, MyTasksState>(
      'loadMyTasks emits loading then empty when no tasks exist',
      build: () {
        when(
          () => repo.getMyTasks(10, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => []);
        return MyTasksCubit(repo);
      },
      act: (cubit) => cubit.loadMyTasks(10),
      expect: () => [
        const MyTasksState.loading(),
        const MyTasksState.empty(workspaceId: 10),
      ],
      verify: (_) {
        verify(() => repo.getMyTasks(10, forceRefresh: false)).called(1);
      },
    );

    final testTasks = [
      // Urgent priority
      const TaskDto(
        id: 1,
        projectId: 1,
        title: 'Urgent Task',
        priority: 'Urgent',
        status: 'Todo',
      ),
      // Overdue task
      TaskDto(
        id: 2,
        projectId: 1,
        title: 'Overdue Task',
        priority: 'Medium',
        status: 'Todo',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      // In Progress task
      const TaskDto(
        id: 3,
        projectId: 1,
        title: 'In Progress Task',
        priority: 'Medium',
        status: 'InProgress',
      ),
      // Up Next task (Todo)
      const TaskDto(
        id: 4,
        projectId: 1,
        title: 'Todo Task',
        priority: 'Low',
        status: 'Todo',
      ),
      // Done task
      TaskDto(
        id: 5,
        projectId: 1,
        title: 'Done Task',
        priority: 'Medium',
        status: 'Done',
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      // Due today (midnight date-only) - should NOT be urgent
      TaskDto(
        id: 6,
        projectId: 1,
        title: 'Due Today Task',
        priority: 'Low',
        status: 'Todo',
        dueDate: DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        ),
      ),
    ];

    blocTest<MyTasksCubit, MyTasksState>(
      'loadMyTasks groups tasks into urgent, inProgress, todo, and done sections',
      build: () {
        when(
          () => repo.getMyTasks(10, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => testTasks);
        return MyTasksCubit(repo);
      },
      act: (cubit) => cubit.loadMyTasks(10),
      expect: () => [
        const MyTasksState.loading(),
        isA<MyTasksLoaded>()
            .having((s) => s.workspaceId, 'workspaceId', 10)
            .having((s) => s.urgentTasks.length, 'urgent count', 2)
            .having((s) => s.inProgressTasks.length, 'inProgress count', 1)
            .having((s) => s.todoTasks.length, 'todo count', 2)
            .having((s) => s.doneTasks.length, 'done count', 1)
            .having((s) => s.showDone, 'showDone', false),
      ],
    );

    blocTest<MyTasksCubit, MyTasksState>(
      'toggleDoneVisibility toggles showDone boolean in loaded state',
      build: () {
        when(
          () => repo.getMyTasks(10, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer(
          (_) async => [
            const TaskDto(
              id: 1,
              projectId: 1,
              title: 'Test Task',
              status: 'Todo',
            ),
          ],
        );
        return MyTasksCubit(repo);
      },
      act: (cubit) async {
        await cubit.loadMyTasks(10);
        cubit.toggleDoneVisibility();
      },
      skip: 2, // skip loading and loaded
      expect: () => [
        isA<MyTasksLoaded>().having((s) => s.showDone, 'showDone', true),
      ],
    );

    blocTest<MyTasksCubit, MyTasksState>(
      'loadMyTasks handles repository error via SafeActionCubit',
      build: () {
        when(
          () => repo.getMyTasks(10, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => throw const AppException(message: 'Network timeout'));
        return MyTasksCubit(repo);
      },
      act: (cubit) => cubit.loadMyTasks(10),
      expect: () => [
        const MyTasksState.loading(),
        isA<MyTasksState>().having(
          (s) => s.maybeWhen(error: (msg) => msg, orElse: () => ''),
          'errorMessage',
          contains('Network timeout'),
        ),
      ],
    );

    group('updateTaskStatus', () {
      const initialTask = TaskDto(
        id: 1,
        projectId: 1,
        title: 'Task 1',
        status: 'Todo',
      );

      blocTest<MyTasksCubit, MyTasksState>(
        'updates task status and refreshes grouped tasks on success',
        build: () {
          when(
            () => repo.getMyTasks(10, forceRefresh: false),
          ).thenAnswer((_) async => [initialTask]);
          when(
            () => repo.updateTaskStatus(1, 'Done'),
          ).thenAnswer((_) async => initialTask.copyWith(status: 'Done'));
          when(
            () => repo.getMyTasks(10, forceRefresh: true),
          ).thenAnswer(
            (_) async => [
              initialTask.copyWith(
                status: 'Done',
                updatedAt: DateTime.now(),
              ),
            ],
          );
          return MyTasksCubit(repo);
        },
        act: (cubit) async {
          await cubit.loadMyTasks(10);
          await cubit.updateTaskStatus(1, 'Done');
        },
        skip: 2,
        expect: () => [
          isA<MyTasksLoaded>()
              .having((s) => s.doneTasks.length, 'doneTasks count', 1)
              .having((s) => s.todoTasks.length, 'todoTasks count', 0),
        ],
        verify: (_) {
          verify(() => repo.updateTaskStatus(1, 'Done')).called(1);
          verify(() => repo.getMyTasks(10, forceRefresh: true)).called(1);
        },
      );

      blocTest<MyTasksCubit, MyTasksState>(
        'emits errorMessage when updateTaskStatus fails',
        build: () {
          when(
            () => repo.getMyTasks(10, forceRefresh: any(named: 'forceRefresh')),
          ).thenAnswer((_) async => [initialTask]);
          when(
            () => repo.updateTaskStatus(1, 'Done'),
          ).thenAnswer((_) async => throw const AppException(message: 'Status update failed'));
          return MyTasksCubit(repo);
        },
        act: (cubit) async {
          await cubit.loadMyTasks(10);
          await cubit.updateTaskStatus(1, 'Done');
        },
        skip: 2,
        expect: () => [
          isA<MyTasksLoaded>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Status update failed'),
          ),
        ],
      );
    });

    group('updateTask', () {
      const initialTask = TaskDto(
        id: 1,
        projectId: 1,
        title: 'Original Title',
        status: 'Todo',
      );
      const updateReq = UpdateTaskRequest(title: 'Updated Title', priority: 'High');

      blocTest<MyTasksCubit, MyTasksState>(
        'updates task and refreshes grouped tasks on success',
        build: () {
          when(
            () => repo.getMyTasks(10, forceRefresh: false),
          ).thenAnswer((_) async => [initialTask]);
          when(
            () => repo.updateTask(1, updateReq),
          ).thenAnswer((_) async => initialTask.copyWith(title: 'Updated Title', priority: 'High'));
          when(
            () => repo.getMyTasks(10, forceRefresh: true),
          ).thenAnswer(
            (_) async => [
              initialTask.copyWith(title: 'Updated Title', priority: 'High'),
            ],
          );
          return MyTasksCubit(repo);
        },
        act: (cubit) async {
          await cubit.loadMyTasks(10);
          await cubit.updateTask(1, updateReq);
        },
        skip: 2,
        expect: () => [
          isA<MyTasksLoaded>()
              .having((s) => s.todoTasks.first.title, 'title', 'Updated Title'),
        ],
        verify: (_) {
          verify(() => repo.updateTask(1, updateReq)).called(1);
          verify(() => repo.getMyTasks(10, forceRefresh: true)).called(1);
        },
      );

      blocTest<MyTasksCubit, MyTasksState>(
        'emits errorMessage when updateTask fails',
        build: () {
          when(
            () => repo.getMyTasks(10, forceRefresh: any(named: 'forceRefresh')),
          ).thenAnswer((_) async => [initialTask]);
          when(
            () => repo.updateTask(1, any()),
          ).thenAnswer((_) async => throw const AppException(message: 'Task update failed'));
          return MyTasksCubit(repo);
        },
        act: (cubit) async {
          await cubit.loadMyTasks(10);
          await cubit.updateTask(1, updateReq);
        },
        skip: 2,
        expect: () => [
          isA<MyTasksLoaded>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Task update failed'),
          ),
        ],
      );
    });

    group('deleteTask', () {
      const task1 = TaskDto(id: 1, projectId: 1, title: 'Task 1', status: 'Todo');
      const task2 = TaskDto(id: 2, projectId: 1, title: 'Task 2', status: 'Todo');

      blocTest<MyTasksCubit, MyTasksState>(
        'deletes task and emits updated tasks list',
        build: () {
          when(
            () => repo.getMyTasks(10, forceRefresh: false),
          ).thenAnswer((_) async => [task1, task2]);
          when(() => repo.deleteTask(1)).thenAnswer((_) async {});
          when(
            () => repo.getMyTasks(10, forceRefresh: true),
          ).thenAnswer((_) async => [task2]);
          return MyTasksCubit(repo);
        },
        act: (cubit) async {
          await cubit.loadMyTasks(10);
          await cubit.deleteTask(1);
        },
        skip: 2,
        expect: () => [
          isA<MyTasksLoaded>().having((s) => s.todoTasks.length, 'todoTasks count', 1),
        ],
        verify: (_) {
          verify(() => repo.deleteTask(1)).called(1);
        },
      );

      blocTest<MyTasksCubit, MyTasksState>(
        'deleting last task transitions state to empty',
        build: () {
          when(
            () => repo.getMyTasks(10, forceRefresh: false),
          ).thenAnswer((_) async => [task1]);
          when(() => repo.deleteTask(1)).thenAnswer((_) async {});
          when(
            () => repo.getMyTasks(10, forceRefresh: true),
          ).thenAnswer((_) async => []);
          return MyTasksCubit(repo);
        },
        act: (cubit) async {
          await cubit.loadMyTasks(10);
          await cubit.deleteTask(1);
        },
        skip: 2,
        expect: () => [
          const MyTasksState.empty(workspaceId: 10),
        ],
      );

      blocTest<MyTasksCubit, MyTasksState>(
        'emits errorMessage when deleteTask fails',
        build: () {
          when(
            () => repo.getMyTasks(10, forceRefresh: any(named: 'forceRefresh')),
          ).thenAnswer((_) async => [task1]);
          when(() => repo.deleteTask(1)).thenAnswer(
            (_) async => throw const AppException(message: 'Delete failed'),
          );
          return MyTasksCubit(repo);
        },
        act: (cubit) async {
          await cubit.loadMyTasks(10);
          await cubit.deleteTask(1);
        },
        skip: 2,
        expect: () => [
          isA<MyTasksLoaded>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Delete failed'),
          ),
        ],
      );
    });

    group('refreshOnFocus', () {
      const task1 = TaskDto(id: 1, projectId: 1, title: 'Task 1', status: 'Todo');
      const task2 = TaskDto(id: 2, projectId: 1, title: 'Task 2', status: 'Todo');

      test('does nothing when workspaceId is null', () async {
        final cubit = MyTasksCubit(repo);
        await cubit.refreshOnFocus();
        expect(cubit.state, const MyTasksState.initial());
        verifyZeroInteractions(repo);
        cubit.close();
      });

      blocTest<MyTasksCubit, MyTasksState>(
        'silently updates tasks on focus without emitting loading',
        build: () {
          when(
            () => repo.getMyTasks(10, forceRefresh: false),
          ).thenAnswer((_) async => [task1]);
          when(
            () => repo.getMyTasks(10, forceRefresh: true),
          ).thenAnswer((_) async => [task1, task2]);
          return MyTasksCubit(repo);
        },
        act: (cubit) async {
          await cubit.loadMyTasks(10);
          await cubit.refreshOnFocus();
        },
        skip: 2,
        expect: () => [
          isA<MyTasksLoaded>().having((s) => s.todoTasks.length, 'todo count', 2),
        ],
        verify: (_) {
          verify(() => repo.getMyTasks(10, forceRefresh: true)).called(1);
        },
      );

      blocTest<MyTasksCubit, MyTasksState>(
        'silently transitions to empty if all tasks are cleared on focus',
        build: () {
          when(
            () => repo.getMyTasks(10, forceRefresh: false),
          ).thenAnswer((_) async => [task1]);
          when(
            () => repo.getMyTasks(10, forceRefresh: true),
          ).thenAnswer((_) async => []);
          return MyTasksCubit(repo);
        },
        act: (cubit) async {
          await cubit.loadMyTasks(10);
          await cubit.refreshOnFocus();
        },
        skip: 2,
        expect: () => [
          const MyTasksState.empty(workspaceId: 10),
        ],
      );

      blocTest<MyTasksCubit, MyTasksState>(
        'absorbs background refresh failure without emitting error',
        build: () {
          when(
            () => repo.getMyTasks(10, forceRefresh: false),
          ).thenAnswer((_) async => [task1]);
          when(
            () => repo.getMyTasks(10, forceRefresh: true),
          ).thenAnswer((_) async => throw const AppException(message: 'Offline'));
          return MyTasksCubit(repo);
        },
        act: (cubit) async {
          await cubit.loadMyTasks(10);
          await cubit.refreshOnFocus();
        },
        skip: 2,
        expect: () => [], // No new states emitted; preserves current view
      );
    });

    group('7-day done cutoff', () {
      final now = DateTime.now();
      final freshDone = TaskDto(
        id: 1,
        projectId: 1,
        title: 'Recent Done',
        status: 'Done',
        updatedAt: now.subtract(const Duration(days: 2)),
      );
      const nullUpdatedDone = TaskDto(
        id: 2,
        projectId: 1,
        title: 'No Date Done',
        status: 'Done',
        updatedAt: null,
      );
      final expiredDone = TaskDto(
        id: 3,
        projectId: 1,
        title: 'Old Done',
        status: 'Done',
        updatedAt: now.subtract(const Duration(days: 9)),
      );

      blocTest<MyTasksCubit, MyTasksState>(
        'includes tasks completed within 7 days or with null updatedAt, excludes tasks older than 7 days',
        build: () {
          when(
            () => repo.getMyTasks(10, forceRefresh: any(named: 'forceRefresh')),
          ).thenAnswer((_) async => [freshDone, nullUpdatedDone, expiredDone]);
          return MyTasksCubit(repo);
        },
        act: (cubit) => cubit.loadMyTasks(10),
        skip: 1, // skip loading
        expect: () => [
          isA<MyTasksLoaded>()
              .having((s) => s.doneTasks.length, 'doneTasks count', 2)
              .having(
                (s) => s.doneTasks.map((t) => t.id),
                'done task ids',
                containsAll([1, 2]),
              )
              .having(
                (s) => s.doneTasks.any((t) => t.id == 3),
                'expired task excluded',
                false,
              ),
        ],
      );
    });
  });
}
