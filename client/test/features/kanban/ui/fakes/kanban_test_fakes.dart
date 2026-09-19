import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';

class TestTaskRepository implements TaskRepository {
  final List<TaskDto> _tasks;
  TestTaskRepository(this._tasks);

  @override
  void clearCache([int? projectId]) {}

  @override
  Future<List<TaskDto>> getTasksByProject(
    int projectId, {
    String? status,
    String? assigneeId,
    String? priority,
    bool forceRefresh = false,
  }) async =>
      _tasks;

  @override
  Future<List<TaskDto>> getMyTasks(
    int workspaceId, {
    bool forceRefresh = false,
  }) async =>
      _tasks;

  @override
  Future<TaskDto> getTask(int taskId, {bool forceRefresh = false}) async =>
      _tasks.firstWhere((t) => t.id == taskId);

  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async =>
      throw UnimplementedError();

  @override
  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request) async =>
      throw UnimplementedError();

  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async =>
      throw UnimplementedError();

  @override
  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteTask(int taskId) async {}

  @override
  bool hasCachedTasks(int projectId) => false;
}

class TestProjectRepository implements ProjectRepository {
  final ProjectDto _project;
  TestProjectRepository(this._project);

  @override
  void clearCache([int? workspaceId]) {}

  @override
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  }) async =>
      [_project];

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async =>
      _project;

  @override
  Future<ProjectDto> createProject(
    int workspaceId,
    CreateProjectRequest request,
  ) async =>
      _project;

  @override
  Future<ProjectDto> updateProject(
    int id,
    UpdateProjectRequest request,
  ) async =>
      _project;

  @override
  Future<void> deleteProject(int id) async {}

  @override
  bool hasCachedProjects(int workspaceId) => false;

  @override
  bool hasCachedProject(int id) => false;
}
