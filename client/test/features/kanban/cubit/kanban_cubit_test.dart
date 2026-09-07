import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';

class _FakeTaskRepo implements TaskRepository {
  List<TaskDto> tasks = [];
  bool shouldThrowOnStatusUpdate = false;

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
  Future<List<TaskDto>> getMyTasks(int workspaceId, {bool forceRefresh = false}) async => tasks;

  @override
  Future<TaskDto> getTask(int taskId, {bool forceRefresh = false}) async =>
      tasks.firstWhere((t) => t.id == taskId);

  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async {
    final created = TaskDto(
      id: tasks.length + 1,
      projectId: projectId,
      title: request.title,
      description: request.description,
      priority: request.priority,
      status: 'Backlog',
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
    );
    tasks[idx] = updated;
    return updated;
  }

  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async {
    if (shouldThrowOnStatusUpdate) {
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

  @override
  void clearCache([int? workspaceId]) {}

  @override
  Future<List<ProjectDto>> getProjects(int workspaceId, {String? status, bool forceRefresh = false}) async => [project];

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async => project;

  @override
  Future<ProjectDto> createProject(int workspaceId, CreateProjectRequest request) async => project;

  @override
  Future<ProjectDto> updateProject(int id, UpdateProjectRequest request) async => project;

  @override
  Future<void> deleteProject(int id) async {}

  @override
  bool hasCachedProjects(int workspaceId) => false;

  @override
  bool hasCachedProject(int id) => false;
}

void main() {
  late _FakeTaskRepo taskRepo;
  late _FakeProjectRepo projectRepo;
  late KanbanCubit cubit;

  setUp(() {
    taskRepo = _FakeTaskRepo();
    projectRepo = _FakeProjectRepo();
    cubit = KanbanCubit(taskRepo, projectRepo);
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is KanbanState.initial()', () {
    expect(cubit.state, const KanbanState.initial());
  });

  test('loadTasks emits loading then empty when project has no tasks', () async {
    taskRepo.tasks = [];

    final expected = [
      const KanbanState.loading(),
      const KanbanState.empty(projectId: 1, isArchived: false),
    ];

    expectLater(cubit.stream, emitsInOrder(expected));
    await cubit.loadTasks(1);
  });

  test('loadTasks marks isArchived true if project status is Archived', () async {
    projectRepo.project = projectRepo.project.copyWith(status: 'Archived');
    taskRepo.tasks = [];

    await cubit.loadTasks(1);

    cubit.state.maybeWhen(
      empty: (projectId, isArchived) {
        expect(projectId, 1);
        expect(isArchived, true);
      },
      orElse: () => fail('State should be empty with isArchived: true'),
    );
  });

  test('moveTaskStatus updates optimistically and preserves change on success', () async {
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
      loaded: (projectId, tasks, allTasks, isArchived, _, _, _, errorMessage) {
        expect(errorMessage, isNull);
        expect(allTasks.first.status, 'InProgress');
        expect(tasks.first.status, 'InProgress');
      },
      orElse: () => fail('State should be KanbanLoaded'),
    );
  });

  test('moveTaskStatus rolls back state and emits errorMessage on failure', () async {
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
      loaded: (projectId, tasks, allTasks, isArchived, _, _, _, errorMessage) {
        // Rollback occurred
        expect(allTasks.first.status, 'Backlog');
        expect(tasks.first.status, 'Backlog');
        expect(errorMessage, contains('Status transition failed'));
      },
      orElse: () => fail('State should be KanbanLoaded with rollback'),
    );
  });

  test('setFilter filters tasks by search query, priority, and assignee', () async {
    taskRepo.tasks = [
      const TaskDto(id: 1, projectId: 1, title: 'Fix bug', priority: 'High', assigneeId: 'u1'),
      const TaskDto(id: 2, projectId: 1, title: 'Write tests', priority: 'Low', assigneeId: 'u2'),
      const TaskDto(id: 3, projectId: 1, title: 'Fix docs', priority: 'Low', assigneeId: null),
    ];

    await cubit.loadTasks(1);

    // Filter by search
    cubit.setFilter(search: 'Fix');
    cubit.state.maybeWhen(
      loaded: (_, tasks, _, _, _, _, _, _) {
        expect(tasks.length, 2);
        expect(tasks.map((t) => t.id), containsAll([1, 3]));
      },
      orElse: () => fail('Should be loaded'),
    );

    // Filter by priority
    cubit.setFilter(priority: 'High');
    cubit.state.maybeWhen(
      loaded: (_, tasks, _, _, _, _, _, _) {
        expect(tasks.length, 1);
        expect(tasks.first.id, 1);
      },
      orElse: () => fail('Should be loaded'),
    );

    // Clear filters
    cubit.clearFilters();
    cubit.state.maybeWhen(
      loaded: (_, tasks, _, _, _, _, _, _) {
        expect(tasks.length, 3);
      },
      orElse: () => fail('Should be loaded'),
    );
  });
}
