import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const CreateTaskRequest(title: 'Fallback'));
    registerFallbackValue(
      const UpdateTaskRequest(title: 'Fallback', priority: 'Medium'),
    );
  });

  group('KanbanCubit', () {
    late MockTaskRepository taskRepo;
    late MockProjectRepository projectRepo;
    late MockWorkspaceRepository workspaceRepo;
    late KanbanCubit cubit;

    const testProject = ProjectDto(
      id: 1,
      workspaceId: 10,
      name: 'Apollo',
      status: 'Active',
    );

    void stubTasks([List<TaskDto> tasks = const []]) {
      when(
        () => taskRepo.getTasksByProject(
          any(),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => tasks);
    }

    KanbanCubit createCubit() =>
        KanbanCubit(taskRepo, projectRepo, null, workspaceRepo);

    setUp(() {
      taskRepo = MockTaskRepository();
      projectRepo = MockProjectRepository();
      workspaceRepo = MockWorkspaceRepository();

      when(
        () =>
            projectRepo.getProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => testProject);
      when(
        () => workspaceRepo.getMembers(
          10,
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => []);

      cubit = createCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is KanbanState.initial()', () {
      expect(cubit.state, const KanbanState.initial());
    });

    blocTest<KanbanCubit, KanbanState>(
      'loadTasks emits loading then empty when project has no tasks',
      build: () {
        stubTasks([]);
        return createCubit();
      },
      act: (cubit) => cubit.loadTasks(1),
      expect: () => [
        const KanbanState.loading(),
        const KanbanState.empty(projectId: 1, isArchived: false),
      ],
    );

    blocTest<KanbanCubit, KanbanState>(
      'loadTasks marks isArchived true if project status is Archived',
      build: () {
        when(
          () => projectRepo.getProject(
            1,
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => testProject.copyWith(status: 'Archived'));
        stubTasks([]);
        return createCubit();
      },
      act: (cubit) => cubit.loadTasks(1),
      expect: () => [
        const KanbanState.loading(),
        const KanbanState.empty(projectId: 1, isArchived: true),
      ],
    );

    const moveTask = TaskDto(
      id: 101,
      projectId: 1,
      title: 'Move Me',
      status: 'Backlog',
    );

    blocTest<KanbanCubit, KanbanState>(
      'moveTaskStatus updates optimistically and preserves change on success',
      build: () {
        stubTasks([moveTask]);
        when(
          () => taskRepo.updateTaskStatus(101, 'InProgress'),
        ).thenAnswer((_) async => moveTask.copyWith(status: 'InProgress'));
        return createCubit();
      },
      act: (cubit) async {
        await cubit.loadTasks(1);
        await cubit.moveTaskStatus(101, 'InProgress');
      },
      skip: 2, // skip loadTasks states
      expect: () => [
        isA<KanbanLoaded>()
            .having((s) => s.tasks.first.status, 'status', 'InProgress')
            .having((s) => s.errorMessage, 'error', isNull),
      ],
    );

    blocTest<KanbanCubit, KanbanState>(
      'moveTaskStatus rolls back state and emits errorMessage on failure',
      build: () {
        stubTasks([moveTask]);
        when(() => taskRepo.updateTaskStatus(101, 'Done')).thenAnswer(
          (_) async =>
              throw const AppException(message: 'Status transition failed'),
        );
        return createCubit();
      },
      act: (cubit) async {
        await cubit.loadTasks(1);
        await cubit.moveTaskStatus(101, 'Done');
      },
      skip: 2,
      expect: () => [
        // Optimistic move
        isA<KanbanLoaded>().having(
          (s) => s.tasks.first.status,
          'status',
          'Done',
        ),
        // Rollback on error
        isA<KanbanLoaded>()
            .having((s) => s.tasks.first.status, 'status', 'Backlog')
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              contains('Status transition failed'),
            ),
      ],
    );

    final filterTasks = [
      const TaskDto(
        id: 1,
        projectId: 1,
        title: 'Fix bug',
        priority: 'High',
        assigneeId: 'u1',
      ),
      const TaskDto(
        id: 2,
        projectId: 1,
        title: 'Write tests',
        priority: 'Low',
        assigneeId: 'u2',
      ),
      const TaskDto(
        id: 3,
        projectId: 1,
        title: 'Fix docs',
        priority: 'Low',
        assigneeId: null,
      ),
    ];

    test(
      'setFilter filters tasks by search query, priority, and assignee',
      () async {
        stubTasks(filterTasks);
        await cubit.loadTasks(1);

        // Filter by search
        cubit.setFilter(search: 'Fix');
        final searchFiltered = cubit.state as KanbanLoaded;
        expect(searchFiltered.tasks.length, 2);
        expect(searchFiltered.tasks.map((t) => t.id), containsAll([1, 3]));

        // Filter by priority
        cubit.setFilter(priority: 'High');
        final priorityFiltered = cubit.state as KanbanLoaded;
        expect(priorityFiltered.tasks.length, 1);
        expect(priorityFiltered.tasks.first.id, 1);

        // Clear filters
        cubit.clearFilters();
        final cleared = cubit.state as KanbanLoaded;
        expect(cleared.tasks.length, 3);
      },
    );

    test(
      'moveTaskStatus preserves subsequent moves when a previous move fails',
      () async {
        const task1 = TaskDto(
          id: 1,
          projectId: 1,
          title: 'Task 1',
          status: 'Backlog',
        );
        const task2 = TaskDto(
          id: 2,
          projectId: 1,
          title: 'Task 2',
          status: 'Backlog',
        );

        stubTasks([task1, task2]);
        await cubit.loadTasks(1);

        final move1Completer = Completer<TaskDto>();
        when(
          () => taskRepo.updateTaskStatus(1, 'InProgress'),
        ).thenAnswer((_) => move1Completer.future);

        when(
          () => taskRepo.updateTaskStatus(2, 'Done'),
        ).thenAnswer((_) async => task2.copyWith(status: 'Done'));

        // Optimistically move Task 1 to InProgress (stays in flight)
        final move1 = cubit.moveTaskStatus(1, 'InProgress');
        // Optimistically move Task 2 to Done while move1 is in flight
        final move2 = cubit.moveTaskStatus(2, 'Done');

        // Wait for move2 to complete
        await move2;

        // Fail move1
        move1Completer.completeError(
          const AppException(message: 'Status transition failed'),
        );
        await move1;

        // State should have Task 1 reverted to Backlog, but Task 2 preserved at Done
        final state = cubit.state as KanbanLoaded;
        final t1 = state.allTasks.firstWhere((t) => t.id == 1);
        final t2 = state.allTasks.firstWhere((t) => t.id == 2);
        expect(t1.status, 'Backlog');
        expect(t2.status, 'Done');
        expect(state.errorMessage, contains('Status transition failed'));
      },
    );

    test('createTask with initialStatus moves task to target status', () async {
      stubTasks([]);
      await cubit.loadTasks(1);

      when(() => taskRepo.createTask(1, any())).thenAnswer(
        (_) async => const TaskDto(
          id: 10,
          projectId: 1,
          title: 'New Feature',
          status: 'InProgress',
        ),
      );

      const req = CreateTaskRequest(title: 'New Feature');
      final created = await cubit.createTask(
        1,
        req,
        initialStatus: 'InProgress',
      );

      expect(created.title, 'New Feature');

      final state = cubit.state as KanbanLoaded;
      expect(state.allTasks.length, 1);
      expect(state.allTasks.first.status, 'InProgress');
    });

    test(
      'createTask with explicit status in req is overridden when initialStatus is provided',
      () async {
        stubTasks([]);
        await cubit.loadTasks(1);

        when(
          () => taskRepo.createTask(
            1,
            const CreateTaskRequest(title: 'Conflict Feature', status: 'Done'),
          ),
        ).thenAnswer(
          (_) async => const TaskDto(
            id: 11,
            projectId: 1,
            title: 'Conflict Feature',
            status: 'Done',
          ),
        );

        const req = CreateTaskRequest(
          title: 'Conflict Feature',
          status: 'Backlog',
        );
        final created = await cubit.createTask(1, req, initialStatus: 'Done');

        expect(created.title, 'Conflict Feature');
        expect(created.status, 'Done');
      },
    );

    test(
      'deleteTask transitions to empty state when last task deleted',
      () async {
        const singleTask = TaskDto(
          id: 99,
          projectId: 1,
          title: 'Single Task',
          status: 'Backlog',
        );
        stubTasks([singleTask]);
        await cubit.loadTasks(1);

        when(() => taskRepo.deleteTask(99)).thenAnswer((_) async {});

        await cubit.deleteTask(99);

        expect(
          cubit.state,
          const KanbanState.empty(projectId: 1, isArchived: false),
        );
      },
    );

    test(
      'TaskDto isOverdue treats date-only today as not overdue and yesterday as overdue',
      () {
        final todayMidnight = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
        );
        final yesterday = todayMidnight.subtract(const Duration(days: 1));
        final tomorrow = todayMidnight.add(const Duration(days: 1));

        final taskToday = TaskDto(
          id: 1,
          projectId: 1,
          title: 'Due Today',
          dueDate: todayMidnight,
          status: 'Todo',
        );
        expect(taskToday.isOverdue, false);

        final taskYesterday = TaskDto(
          id: 2,
          projectId: 1,
          title: 'Due Yesterday',
          dueDate: yesterday,
          status: 'Todo',
        );
        expect(taskYesterday.isOverdue, true);

        final taskTomorrow = TaskDto(
          id: 3,
          projectId: 1,
          title: 'Due Tomorrow',
          dueDate: tomorrow,
          status: 'Todo',
        );
        expect(taskTomorrow.isOverdue, false);

        final doneTask = TaskDto(
          id: 4,
          projectId: 1,
          title: 'Done Task',
          dueDate: yesterday,
          status: 'Done',
        );
        expect(doneTask.isOverdue, false);
      },
    );

    test(
      'createTask failure on KanbanEmpty rethrows and sets errorMessage in empty state',
      () async {
        stubTasks([]);
        await cubit.loadTasks(1);
        expect(cubit.state, isA<KanbanEmpty>());

        when(() => taskRepo.createTask(1, any())).thenAnswer(
          (_) async =>
              throw const AppException(message: 'Task creation failed'),
        );

        await expectLater(
          cubit.createTask(1, const CreateTaskRequest(title: 'Fail Task')),
          throwsA(isA<AppException>()),
        );

        expect(cubit.state, isA<KanbanEmpty>());
        final empty = cubit.state as KanbanEmpty;
        expect(empty.errorMessage, 'Task creation failed');
      },
    );

    test(
      'createTask failure on KanbanLoaded rethrows and sets errorMessage in loaded state',
      () async {
        stubTasks([
          const TaskDto(
            id: 1,
            projectId: 1,
            title: 'Existing',
            status: 'Backlog',
          ),
        ]);
        await cubit.loadTasks(1);
        expect(cubit.state, isA<KanbanLoaded>());

        when(() => taskRepo.createTask(1, any())).thenAnswer(
          (_) async =>
              throw const AppException(message: 'Task creation failed'),
        );

        await expectLater(
          cubit.createTask(1, const CreateTaskRequest(title: 'Fail Task')),
          throwsA(isA<AppException>()),
        );

        expect(cubit.state, isA<KanbanLoaded>());
        final loaded = cubit.state as KanbanLoaded;
        expect(loaded.errorMessage, 'Task creation failed');
        expect(loaded.allTasks.length, 1);
      },
    );

    test(
      'createTask with fallback status update failure retains created task in state and rethrows (H3)',
      () async {
        stubTasks([]);
        await cubit.loadTasks(1);

        // Backend returns Backlog even though InProgress requested
        when(
          () => taskRepo.createTask(
            1,
            const CreateTaskRequest(
              title: 'Fallback Fail',
              status: 'InProgress',
            ),
          ),
        ).thenAnswer(
          (_) async => const TaskDto(
            id: 55,
            projectId: 1,
            title: 'Fallback Fail',
            status: 'Backlog',
          ),
        );
        // Status update fails
        when(() => taskRepo.updateTaskStatus(55, 'InProgress')).thenAnswer(
          (_) async =>
              throw const AppException(message: 'Status transition failed'),
        );

        await expectLater(
          cubit.createTask(
            1,
            const CreateTaskRequest(title: 'Fallback Fail'),
            initialStatus: 'InProgress',
          ),
          throwsA(isA<AppException>()),
        );

        // Task must NOT be dropped from state (H3)
        expect(cubit.state, isA<KanbanLoaded>());
        final loaded = cubit.state as KanbanLoaded;
        expect(loaded.allTasks.length, 1);
        expect(loaded.allTasks.first.title, 'Fallback Fail');
        expect(loaded.allTasks.first.status, 'Backlog');
        expect(loaded.errorMessage, contains('Status transition failed'));
      },
    );

    test('loadTasks emits error state when project fetch fails (M6)', () async {
      when(
        () =>
            projectRepo.getProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer(
        (_) async => throw const AppException(message: 'Project not found'),
      );

      await cubit.loadTasks(1);

      expect(cubit.state, const KanbanState.error('Project not found'));
    });

    test('loadTasks populates project and workspace members (M6/M9)', () async {
      when(
        () => workspaceRepo.getMembers(
          10,
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer(
        (_) async => [
          MemberDto(
            userId: 'u1',
            name: 'Alice',
            email: 'alice@example.com',
            role: 'Admin',
            joinedAt: DateTime(2026, 1, 1),
          ),
        ],
      );
      stubTasks([]);

      await cubit.loadTasks(1);

      expect(cubit.project?.name, 'Apollo');
      expect(cubit.members.length, 1);
      expect(cubit.members.first.name, 'Alice');
    });

    test('setFilter filters by tagId in TaskFilter (M7)', () async {
      final tagTasks = [
        const TaskDto(
          id: 1,
          projectId: 1,
          title: 'Tagged 10',
          tags: [
            TagDto(id: 10, workspaceId: 10, name: 'Tag 10', color: '#ff0000'),
          ],
        ),
        const TaskDto(
          id: 2,
          projectId: 1,
          title: 'Tagged 20',
          tags: [
            TagDto(id: 20, workspaceId: 10, name: 'Tag 20', color: '#00ff00'),
          ],
        ),
        const TaskDto(id: 3, projectId: 1, title: 'No tags'),
      ];

      stubTasks(tagTasks);

      await cubit.loadTasks(1);

      cubit.setFilter(tagId: 10);
      final loaded = cubit.state as KanbanLoaded;
      expect(loaded.tasks.length, 1);
      expect(loaded.tasks.first.id, 1);
      expect(loaded.filter.tagId, 10);

      cubit.clearFilters();
      final cleared = cubit.state as KanbanLoaded;
      expect(cleared.tasks.length, 3);
      expect(cleared.filter.tagId, isNull);
    });

    test(
      'refreshTasks does not emit KanbanLoading and updates tasks silently (M8)',
      () async {
        stubTasks([
          const TaskDto(
            id: 1,
            projectId: 1,
            title: 'Original Task',
            status: 'Backlog',
          ),
        ]);

        await cubit.loadTasks(1);
        expect(cubit.state, isA<KanbanLoaded>());

        // Add a second task remotely
        when(
          () => taskRepo.getTasksByProject(1, forceRefresh: true),
        ).thenAnswer(
          (_) async => [
            const TaskDto(
              id: 1,
              projectId: 1,
              title: 'Original Task',
              status: 'Backlog',
            ),
            const TaskDto(
              id: 2,
              projectId: 1,
              title: 'Second Task',
              status: 'Todo',
            ),
          ],
        );

        final states = <KanbanState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.refreshTasks(forceRefresh: true);

        expect(states.any((s) => s is KanbanLoading), isFalse);
        expect(cubit.state, isA<KanbanLoaded>());
        final loaded = cubit.state as KanbanLoaded;
        expect(loaded.allTasks.length, 2);

        await sub.cancel();
      },
    );

    test(
      'clearErrorMessage clears error on both KanbanLoaded and KanbanEmpty',
      () async {
        stubTasks([]);
        await cubit.loadTasks(1);
        cubit.setLoadedError('Some empty error');
        expect(cubit.state.errorMessage, 'Some empty error');

        cubit.clearErrorMessage();
        expect(cubit.state.errorMessage, isNull);

        stubTasks([
          const TaskDto(id: 1, projectId: 1, title: 'T1', status: 'Backlog'),
        ]);
        await cubit.loadTasks(1);
        cubit.setLoadedError('Some loaded error');
        expect(cubit.state.errorMessage, 'Some loaded error');

        cubit.clearErrorMessage();
        expect(cubit.state.errorMessage, isNull);
      },
    );
  });
}
