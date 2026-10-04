import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

class _FakeTaskRepo implements TaskRepository {
  List<TaskDto> tasks = [];
  bool shouldThrowOnCreate = false;
  bool shouldThrowOnStatusUpdate = false;
  bool shouldThrowOnDelete = false;
  bool alwaysReturnBacklogOnCreate = false;
  int? throwOnTaskId;

  @override
  void clearCache([int? projectId]) {}

  @override
  Future<List<TaskDto>> getTasksByProject(
    int projectId, {
    String? status,
    String? assigneeId,
    String? priority,
    bool forceRefresh = false,
  }) async => tasks;

  @override
  Future<List<TaskDto>> getMyTasks(
    int workspaceId, {
    bool forceRefresh = false,
  }) async => tasks;

  @override
  Future<TaskDto> getTask(int taskId, {bool forceRefresh = false}) async =>
      tasks.firstWhere((t) => t.id == taskId);

  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async {
    if (shouldThrowOnCreate) {
      throw const AppException(message: 'Task creation failed');
    }
    final created = TaskDto(
      id: tasks.length + 1,
      projectId: projectId,
      title: request.title,
      description: request.description,
      priority: request.priority,
      status: alwaysReturnBacklogOnCreate ? 'Backlog' : (request.status ?? 'Backlog'),
      assigneeId: request.assigneeId,
      tags: request.tagIds
          .map(
            (id) => TagDto(
              id: id,
              workspaceId: 10,
              name: 'Tag $id',
              color: '#000000',
            ),
          )
          .toList(),
    );
    tasks.add(created);
    return created;
  }

  @override
  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request) async {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    final updated = tasks[idx].copyWith(
      title: request.title,
      description: request.description,
      priority: request.priority,
      assigneeId: request.assigneeId,
    );
    tasks[idx] = updated;
    return updated;
  }

  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async {
    if (shouldThrowOnStatusUpdate || throwOnTaskId == taskId) {
      throw const AppException(message: 'Status transition failed');
    }
    final idx = tasks.indexWhere((t) => t.id == taskId);
    final updated = tasks[idx].copyWith(status: status);
    tasks[idx] = updated;
    return updated;
  }

  @override
  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId) async {
    final idx = tasks.indexWhere((t) => t.id == taskId);
    final updated = tasks[idx].copyWith(assigneeId: assigneeId);
    tasks[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteTask(int taskId) async {
    if (shouldThrowOnDelete) {
      throw const AppException(message: 'Delete failed');
    }
    tasks.removeWhere((t) => t.id == taskId);
  }

  @override
  bool hasCachedTasks(int projectId) => false;
}

class _FakeProjectRepo implements ProjectRepository {
  ProjectDto project = const ProjectDto(
    id: 1,
    workspaceId: 10,
    name: 'Apollo',
    status: 'Active',
  );
  bool shouldThrowOnGetProject = false;

  @override
  void clearCache([int? workspaceId]) {}

  @override
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  }) async => [project];

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async {
    if (shouldThrowOnGetProject) {
      throw const AppException(message: 'Project not found');
    }
    return project;
  }

  @override
  Future<ProjectDto> createProject(
    int workspaceId,
    CreateProjectRequest request,
  ) async => project;

  @override
  Future<ProjectDto> updateProject(
    int id,
    UpdateProjectRequest request,
  ) async => project;

  @override
  Future<void> deleteProject(int id) async {}

  @override
  bool hasCachedProjects(int workspaceId) => false;

  @override
  bool hasCachedProject(int id) => false;
}

class _FakeWorkspaceRepo implements WorkspaceRepository {
  List<MemberDto> members = [];
  bool shouldThrow = false;

  @override
  Stream<WorkspaceDto?> get activeWorkspaceChanges => const Stream.empty();
  @override
  WorkspaceDto? get activeWorkspace => null;
  @override
  void setActiveWorkspace(WorkspaceDto? workspace) {}
  @override
  Future<List<WorkspaceDto>> getWorkspaces() async => [];
  @override
  Future<WorkspaceDto> getWorkspace(int id, {bool forceRefresh = false}) async =>
      throw UnimplementedError();
  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request) async =>
      throw UnimplementedError();
  @override
  Future<WorkspaceDto> updateWorkspace(int id, UpdateWorkspaceRequest request) async =>
      throw UnimplementedError();
  @override
  Future<void> deleteWorkspace(int id) async {}
  @override
  Future<List<MemberDto>> getMembers(
    int workspaceId, {
    bool forceRefresh = false,
  }) async {
    if (shouldThrow) {
      throw const AppException(message: 'Failed to fetch members');
    }
    return members;
  }
  @override
  Future<MemberDto> addMember(int workspaceId, AddMemberRequest request) async =>
      throw UnimplementedError();
  @override
  Future<void> removeMember(int workspaceId, String userId) async {}
  @override
  Future<MemberDto> updateMemberRole(
    int workspaceId,
    String userId,
    String role,
  ) async => throw UnimplementedError();
  @override
  bool hasCachedSettings(int workspaceId) => false;
  @override
  void clearCache([int? workspaceId]) {}
  @override
  void dispose() {}
}

void main() {
  late _FakeTaskRepo taskRepo;
  late _FakeProjectRepo projectRepo;
  late _FakeWorkspaceRepo workspaceRepo;
  late KanbanCubit cubit;

  setUp(() {
    taskRepo = _FakeTaskRepo();
    projectRepo = _FakeProjectRepo();
    workspaceRepo = _FakeWorkspaceRepo();
    cubit = KanbanCubit(taskRepo, projectRepo, null, workspaceRepo);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is KanbanState.initial()', () {
    expect(cubit.state, const KanbanState.initial());
  });

  test(
    'loadTasks emits loading then empty when project has no tasks',
    () async {
      taskRepo.tasks = [];

      final expected = [
        const KanbanState.loading(),
        const KanbanState.empty(projectId: 1, isArchived: false),
      ];

      expectLater(cubit.stream, emitsInOrder(expected));
      await cubit.loadTasks(1);
    },
  );

  test(
    'loadTasks marks isArchived true if project status is Archived',
    () async {
      projectRepo.project = projectRepo.project.copyWith(status: 'Archived');
      taskRepo.tasks = [];

      await cubit.loadTasks(1);

      cubit.state.maybeWhen(
        empty: (projectId, isArchived, _) {
          expect(projectId, 1);
          expect(isArchived, true);
        },
        orElse: () => fail('State should be empty with isArchived: true'),
      );
    },
  );

  test(
    'moveTaskStatus updates optimistically and preserves change on success',
    () async {
      taskRepo.tasks = [
        const TaskDto(
          id: 101,
          projectId: 1,
          title: 'Move Me',
          status: 'Backlog',
        ),
      ];

      await cubit.loadTasks(1);

      await cubit.moveTaskStatus(101, 'InProgress');

      cubit.state.maybeWhen(
        loaded:
            (projectId, tasks, allTasks, isArchived, filter, errorMessage) {
              expect(errorMessage, isNull);
              expect(allTasks.first.status, 'InProgress');
              expect(tasks.first.status, 'InProgress');
            },
        orElse: () => fail('State should be KanbanLoaded'),
      );
    },
  );

  test(
    'moveTaskStatus rolls back state and emits errorMessage on failure',
    () async {
      taskRepo.tasks = [
        const TaskDto(
          id: 101,
          projectId: 1,
          title: 'Fail Move',
          status: 'Backlog',
        ),
      ];
      taskRepo.shouldThrowOnStatusUpdate = true;

      await cubit.loadTasks(1);

      await cubit.moveTaskStatus(101, 'Done');

      cubit.state.maybeWhen(
        loaded:
            (projectId, tasks, allTasks, isArchived, filter, errorMessage) {
              // Rollback occurred
              expect(allTasks.first.status, 'Backlog');
              expect(tasks.first.status, 'Backlog');
              expect(errorMessage, contains('Status transition failed'));
            },
        orElse: () => fail('State should be KanbanLoaded with rollback'),
      );
    },
  );

  test(
    'setFilter filters tasks by search query, priority, and assignee',
    () async {
      taskRepo.tasks = [
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
    },
  );

  test(
    'moveTaskStatus preserves subsequent moves when a previous move fails',
    () async {
      taskRepo.tasks = [
        const TaskDto(id: 1, projectId: 1, title: 'Task 1', status: 'Backlog'),
        const TaskDto(id: 2, projectId: 1, title: 'Task 2', status: 'Backlog'),
      ];

      await cubit.loadTasks(1);

      // Task 1 will fail on the server, Task 2 will succeed
      taskRepo.throwOnTaskId = 1;

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
    },
  );

  test('createTask with initialStatus moves task to target status', () async {
    taskRepo.tasks = [];
    await cubit.loadTasks(1);

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

  test(
    'deleteTask transitions to empty state when last task deleted',
    () async {
      taskRepo.tasks = [
        const TaskDto(
          id: 99,
          projectId: 1,
          title: 'Single Task',
          status: 'Backlog',
        ),
      ];
      await cubit.loadTasks(1);

      await cubit.deleteTask(99);

      cubit.state.maybeWhen(
        empty: (projectId, isArchived, _) {
          expect(projectId, 1);
          expect(isArchived, false);
        },
        orElse: () => fail('State should be KanbanState.empty'),
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

  // --- Resilience & Error State Tests (H1, H3, M6/M9, M7, M8) ---

  test('createTask failure on KanbanEmpty rethrows and sets errorMessage in empty state', () async {
    taskRepo.tasks = [];
    await cubit.loadTasks(1);
    expect(cubit.state, isA<KanbanEmpty>());

    taskRepo.shouldThrowOnCreate = true;
    await expectLater(
      cubit.createTask(1, const CreateTaskRequest(title: 'Fail Task')),
      throwsA(isA<AppException>()),
    );

    expect(cubit.state, isA<KanbanEmpty>());
    final empty = cubit.state as KanbanEmpty;
    expect(empty.errorMessage, 'Task creation failed');
  });

  test('createTask failure on KanbanLoaded rethrows and sets errorMessage in loaded state', () async {
    taskRepo.tasks = [
      const TaskDto(id: 1, projectId: 1, title: 'Existing', status: 'Backlog'),
    ];
    await cubit.loadTasks(1);
    expect(cubit.state, isA<KanbanLoaded>());

    taskRepo.shouldThrowOnCreate = true;
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
    taskRepo.tasks = [];
    await cubit.loadTasks(1);

    // Simulate backend ignoring status (returning Backlog) and status update failing
    taskRepo.alwaysReturnBacklogOnCreate = true;
    taskRepo.shouldThrowOnStatusUpdate = true;
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
    projectRepo.shouldThrowOnGetProject = true;

    await cubit.loadTasks(1);

    expect(cubit.state, const KanbanState.error('Project not found'));
  });

  test('loadTasks populates project and workspace members (M6/M9)', () async {
    workspaceRepo.members = [
      MemberDto(
        userId: 'u1',
        name: 'Alice',
        email: 'alice@example.com',
        role: 'Admin',
        joinedAt: DateTime(2026, 1, 1),
      ),
    ];

    await cubit.loadTasks(1);

    expect(cubit.project?.name, 'Apollo');
    expect(cubit.members.length, 1);
    expect(cubit.members.first.name, 'Alice');
  });

  test('setFilter filters by tagId in TaskFilter (M7)', () async {
    taskRepo.tasks = [
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
    taskRepo.tasks = [
      const TaskDto(id: 1, projectId: 1, title: 'Original Task', status: 'Backlog'),
    ];

    await cubit.loadTasks(1);
    expect(cubit.state, isA<KanbanLoaded>());

    // Add a second task remotely
    taskRepo.tasks = [
      const TaskDto(id: 1, projectId: 1, title: 'Original Task', status: 'Backlog'),
      const TaskDto(id: 2, projectId: 1, title: 'Second Task', status: 'Todo'),
    ];

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
    taskRepo.tasks = [];
    await cubit.loadTasks(1);
    cubit.setLoadedError('Some empty error');
    expect(cubit.state.errorMessage, 'Some empty error');

    cubit.clearErrorMessage();
    expect(cubit.state.errorMessage, isNull);

    taskRepo.tasks = [
      const TaskDto(id: 1, projectId: 1, title: 'T1', status: 'Backlog'),
    ];
    await cubit.loadTasks(1);
    cubit.setLoadedError('Some loaded error');
    expect(cubit.state.errorMessage, 'Some loaded error');

    cubit.clearErrorMessage();
    expect(cubit.state.errorMessage, isNull);
  });
}
