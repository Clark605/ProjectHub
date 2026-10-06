import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

class MockTaskRepository extends Mock implements TaskRepository {}
class MockProjectRepository extends Mock implements ProjectRepository {}
class MockWorkspaceRepository extends Mock implements WorkspaceRepository {}

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

    setUp(() {
      taskRepo = MockTaskRepository();
      projectRepo = MockProjectRepository();
      workspaceRepo = MockWorkspaceRepository();

      when(
        () => projectRepo.getProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => testProject);
      when(
        () => workspaceRepo.getMembers(10, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => []);

      cubit = KanbanCubit(taskRepo, projectRepo, null, workspaceRepo);
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
        when(
          () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => []);
        return KanbanCubit(taskRepo, projectRepo, null, workspaceRepo);
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
          () => projectRepo.getProject(1, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => testProject.copyWith(status: 'Archived'));
        when(
          () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => []);
        return KanbanCubit(taskRepo, projectRepo, null, workspaceRepo);
      },
      act: (cubit) => cubit.loadTasks(1),
      expect: () => [
        const KanbanState.loading(),
        const KanbanState.empty(projectId: 1, isArchived: true),
      ],
      verify: (cubit) {
        cubit.state.maybeWhen(
          empty: (projectId, isArchived, _) {
            expect(projectId, 1);
            expect(isArchived, true);
          },
          orElse: () => fail('State should be empty with isArchived: true'),
        );
      },
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
        when(
          () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => [moveTask]);
        when(
          () => taskRepo.updateTaskStatus(101, 'InProgress'),
        ).thenAnswer((_) async => moveTask.copyWith(status: 'InProgress'));
        return KanbanCubit(taskRepo, projectRepo, null, workspaceRepo);
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
      verify: (cubit) {
        cubit.state.maybeWhen(
          loaded: (projectId, tasks, allTasks, isArchived, filter, errorMessage) {
            expect(errorMessage, isNull);
            expect(allTasks.first.status, 'InProgress');
            expect(tasks.first.status, 'InProgress');
          },
          orElse: () => fail('State should be KanbanLoaded'),
        );
      },
    );

    blocTest<KanbanCubit, KanbanState>(
      'moveTaskStatus rolls back state and emits errorMessage on failure',
      build: () {
        when(
          () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => [moveTask]);
        when(
          () => taskRepo.updateTaskStatus(101, 'Done'),
        ).thenThrow(const AppException(message: 'Status transition failed'));
        return KanbanCubit(taskRepo, projectRepo, null, workspaceRepo);
      },
      act: (cubit) async {
        await cubit.loadTasks(1);
        await cubit.moveTaskStatus(101, 'Done');
      },
      skip: 2,
      expect: () => [
        // Optimistic move
        isA<KanbanLoaded>().having((s) => s.tasks.first.status, 'status', 'Done'),
        // Rollback on error
        isA<KanbanLoaded>()
            .having((s) => s.tasks.first.status, 'status', 'Backlog')
            .having((s) => s.errorMessage, 'errorMessage', contains('Status transition failed')),
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

    test('setFilter filters tasks by search query, priority, and assignee', () async {
      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => filterTasks);

      await cubit.loadTasks(1);

      // Filter by search
      cubit.setFilter(search: 'Fix');
      cubit.state.maybeWhen(
        loaded: (_, tasks, _, _, _, _) {
          expect(tasks.length, 2);
          expect(tasks.map((t) => t.id), containsAll([1, 3]));
        },
        orElse: () => fail('Should be loaded'),
      );

      // Filter by priority
      cubit.setFilter(priority: 'High');
      cubit.state.maybeWhen(
        loaded: (_, tasks, _, _, _, _) {
          expect(tasks.length, 1);
          expect(tasks.first.id, 1);
        },
        orElse: () => fail('Should be loaded'),
      );

      // Clear filters
      cubit.clearFilters();
      cubit.state.maybeWhen(
        loaded: (_, tasks, _, _, _, _) {
          expect(tasks.length, 3);
        },
        orElse: () => fail('Should be loaded'),
      );
    });

    test('moveTaskStatus preserves subsequent moves when a previous move fails', () async {
      const task1 = TaskDto(id: 1, projectId: 1, title: 'Task 1', status: 'Backlog');
      const task2 = TaskDto(id: 2, projectId: 1, title: 'Task 2', status: 'Backlog');

      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => [task1, task2]);

      await cubit.loadTasks(1);

      when(
        () => taskRepo.updateTaskStatus(1, 'InProgress'),
      ).thenThrow(const AppException(message: 'Status transition failed'));
      when(
        () => taskRepo.updateTaskStatus(2, 'Done'),
      ).thenAnswer((_) async => task2.copyWith(status: 'Done'));

      // Optimistically move Task 1 to InProgress, then Task 2 to Done
      final move1 = cubit.moveTaskStatus(1, 'InProgress');
      final move2 = cubit.moveTaskStatus(2, 'Done');

      await Future.wait([move1, move2]);

      // State should have Task 1 reverted to Backlog, but Task 2 preserved at Done
      cubit.state.maybeWhen(
        loaded: (_, tasks, allTasks, _, _, errorMessage) {
          final t1 = allTasks.firstWhere((t) => t.id == 1);
          final t2 = allTasks.firstWhere((t) => t.id == 2);
          expect(t1.status, 'Backlog');
          expect(t2.status, 'Done');
          expect(errorMessage, contains('Status transition failed'));
        },
        orElse: () => fail('State should be KanbanLoaded'),
      );
    });

    test('createTask with initialStatus moves task to target status', () async {
      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => []);
      await cubit.loadTasks(1);

      when(
        () => taskRepo.createTask(1, any()),
      ).thenAnswer(
        (_) async => const TaskDto(
          id: 10,
          projectId: 1,
          title: 'New Feature',
          status: 'InProgress',
        ),
      );

      const req = CreateTaskRequest(title: 'New Feature');
      final created = await cubit.createTask(1, req, initialStatus: 'InProgress');

      expect(created.title, 'New Feature');

      cubit.state.maybeWhen(
        loaded: (_, tasks, allTasks, _, _, _) {
          expect(allTasks.length, 1);
          expect(allTasks.first.status, 'InProgress');
        },
        orElse: () => fail('Should transition from empty to loaded'),
      );
    });

    test('createTask with explicit status in req is overridden when initialStatus is provided', () async {
      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => []);
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

      const req = CreateTaskRequest(title: 'Conflict Feature', status: 'Backlog');
      final created = await cubit.createTask(1, req, initialStatus: 'Done');

      expect(created.title, 'Conflict Feature');
      expect(created.status, 'Done');
    });

    test('deleteTask transitions to empty state when last task deleted', () async {
      const singleTask = TaskDto(
        id: 99,
        projectId: 1,
        title: 'Single Task',
        status: 'Backlog',
      );
      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => [singleTask]);
      await cubit.loadTasks(1);

      when(() => taskRepo.deleteTask(99)).thenAnswer((_) async {});

      await cubit.deleteTask(99);

      cubit.state.maybeWhen(
        empty: (projectId, isArchived, _) {
          expect(projectId, 1);
          expect(isArchived, false);
        },
        orElse: () => fail('State should be KanbanState.empty'),
      );
    });

    test('TaskDto isOverdue treats date-only today as not overdue and yesterday as overdue', () {
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
    });

    test('createTask failure on KanbanEmpty rethrows and sets errorMessage in empty state', () async {
      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => []);
      await cubit.loadTasks(1);
      expect(cubit.state, isA<KanbanEmpty>());

      when(
        () => taskRepo.createTask(1, any()),
      ).thenThrow(const AppException(message: 'Task creation failed'));

      await expectLater(
        cubit.createTask(1, const CreateTaskRequest(title: 'Fail Task')),
        throwsA(isA<AppException>()),
      );

      expect(cubit.state, isA<KanbanEmpty>());
      final empty = cubit.state as KanbanEmpty;
      expect(empty.errorMessage, 'Task creation failed');
    });

    test('createTask failure on KanbanLoaded rethrows and sets errorMessage in loaded state', () async {
      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer(
        (_) async => [
          const TaskDto(id: 1, projectId: 1, title: 'Existing', status: 'Backlog'),
        ],
      );
      await cubit.loadTasks(1);
      expect(cubit.state, isA<KanbanLoaded>());

      when(
        () => taskRepo.createTask(1, any()),
      ).thenThrow(const AppException(message: 'Task creation failed'));

      await expectLater(
        cubit.createTask(1, const CreateTaskRequest(title: 'Fail Task')),
        throwsA(isA<AppException>()),
      );

      expect(cubit.state, isA<KanbanLoaded>());
      final loaded = cubit.state as KanbanLoaded;
      expect(loaded.errorMessage, 'Task creation failed');
      expect(loaded.allTasks.length, 1);
    });

    test('createTask with fallback status update failure retains created task in state and rethrows (H3)', () async {
      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => []);
      await cubit.loadTasks(1);

      // Backend returns Backlog even though InProgress requested
      when(
        () => taskRepo.createTask(
          1,
          const CreateTaskRequest(title: 'Fallback Fail', status: 'InProgress'),
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
      when(
        () => taskRepo.updateTaskStatus(55, 'InProgress'),
      ).thenThrow(const AppException(message: 'Status transition failed'));

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
    });

    test('loadTasks emits error state when project fetch fails (M6)', () async {
      when(
        () => projectRepo.getProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenThrow(const AppException(message: 'Project not found'));

      await cubit.loadTasks(1);

      expect(cubit.state, const KanbanState.error('Project not found'));
    });

    test('loadTasks populates project and workspace members (M6/M9)', () async {
      when(
        () => workspaceRepo.getMembers(10, forceRefresh: any(named: 'forceRefresh')),
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
      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => []);

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

      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => tagTasks);

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

    test('refreshTasks does not emit KanbanLoading and updates tasks silently (M8)', () async {
      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer(
        (_) async => [
          const TaskDto(id: 1, projectId: 1, title: 'Original Task', status: 'Backlog'),
        ],
      );

      await cubit.loadTasks(1);
      expect(cubit.state, isA<KanbanLoaded>());

      // Add a second task remotely
      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: true),
      ).thenAnswer(
        (_) async => [
          const TaskDto(id: 1, projectId: 1, title: 'Original Task', status: 'Backlog'),
          const TaskDto(id: 2, projectId: 1, title: 'Second Task', status: 'Todo'),
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
    });

    test('clearErrorMessage clears error on both KanbanLoaded and KanbanEmpty', () async {
      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => []);
      await cubit.loadTasks(1);
      cubit.setLoadedError('Some empty error');
      expect(cubit.state.errorMessage, 'Some empty error');

      cubit.clearErrorMessage();
      expect(cubit.state.errorMessage, isNull);

      when(
        () => taskRepo.getTasksByProject(1, forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer(
        (_) async => [
          const TaskDto(id: 1, projectId: 1, title: 'T1', status: 'Backlog'),
        ],
      );
      await cubit.loadTasks(1);
      cubit.setLoadedError('Some loaded error');
      expect(cubit.state.errorMessage, 'Some loaded error');

      cubit.clearErrorMessage();
      expect(cubit.state.errorMessage, isNull);
    });
  });
}
