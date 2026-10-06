import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/tasks/cubit/my_tasks_cubit.dart';
import 'package:client/features/tasks/cubit/my_tasks_state.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/task_repository.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

void main() {
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
        ).thenThrow(const AppException(message: 'Network timeout'));
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
  });
}
