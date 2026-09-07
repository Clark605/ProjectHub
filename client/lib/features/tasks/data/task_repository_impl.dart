import 'package:injectable/injectable.dart';

import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_remote_data_source.dart';
import 'package:client/features/tasks/data/task_repository.dart';

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource _remoteDataSource;
  final Map<int, List<TaskDto>> _projectTasksCache = {};
  final Map<int, TaskDto> _taskDetailCache = {};
  final Map<int, List<TaskDto>> _myTasksCache = {};

  TaskRepositoryImpl(this._remoteDataSource);

  @override
  void clearCache([int? projectId]) {
    AppLogger.debug(
      projectId != null
          ? 'Clearing task cache for project $projectId'
          : 'Clearing all task caches',
      tag: 'TaskRepository',
    );
    if (projectId != null) {
      _projectTasksCache.remove(projectId);
      _taskDetailCache.removeWhere((_, t) => t.projectId == projectId);
    } else {
      _projectTasksCache.clear();
      _taskDetailCache.clear();
      _myTasksCache.clear();
    }
  }

  @override
  Future<List<TaskDto>> getTasksByProject(
    int projectId, {
    String? status,
    String? assigneeId,
    String? priority,
    bool forceRefresh = false,
  }) async {
    final hasFilter =
        (status != null &&
            status.isNotEmpty &&
            status.toLowerCase() != 'all') ||
        (assigneeId != null && assigneeId.isNotEmpty) ||
        (priority != null &&
            priority.isNotEmpty &&
            priority.toLowerCase() != 'all');

    if (!forceRefresh &&
        !hasFilter &&
        _projectTasksCache.containsKey(projectId)) {
      AppLogger.debug(
        'Cache hit for project $projectId tasks',
        tag: 'TaskRepository',
      );
      return _projectTasksCache[projectId]!;
    }

    final tasks = await _remoteDataSource.getTasksByProject(
      projectId,
      status: status,
      assigneeId: assigneeId,
      priority: priority,
    );

    for (final t in tasks) {
      _taskDetailCache[t.id] = t;
    }

    if (!hasFilter) {
      _projectTasksCache[projectId] = tasks;
    }

    return tasks;
  }

  @override
  Future<List<TaskDto>> getMyTasks(
    int workspaceId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _myTasksCache.containsKey(workspaceId)) {
      AppLogger.debug(
        'Cache hit for workspace $workspaceId my-tasks',
        tag: 'TaskRepository',
      );
      return _myTasksCache[workspaceId]!;
    }

    final tasks = await _remoteDataSource.getMyTasks(workspaceId);

    for (final t in tasks) {
      _taskDetailCache[t.id] = t;
    }

    _myTasksCache[workspaceId] = tasks;
    return tasks;
  }

  @override
  Future<TaskDto> getTask(int taskId, {bool forceRefresh = false}) async {
    if (!forceRefresh && _taskDetailCache.containsKey(taskId)) {
      AppLogger.debug(
        'Cache hit for task $taskId detail',
        tag: 'TaskRepository',
      );
      return _taskDetailCache[taskId]!;
    }

    final task = await _remoteDataSource.getTask(taskId);
    _taskDetailCache[taskId] = task;

    if (_projectTasksCache.containsKey(task.projectId)) {
      final list = _projectTasksCache[task.projectId]!;
      final index = list.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        list[index] = task;
      } else {
        list.add(task);
      }
    }

    return task;
  }

  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async {
    final created = await _remoteDataSource.createTask(projectId, request);
    _taskDetailCache[created.id] = created;

    if (_projectTasksCache.containsKey(projectId)) {
      _projectTasksCache[projectId] = [
        created,
        ..._projectTasksCache[projectId]!,
      ];
    }
    _myTasksCache.clear();

    return created;
  }

  @override
  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request) async {
    final updated = await _remoteDataSource.updateTask(taskId, request);
    _taskDetailCache[taskId] = updated;

    if (_projectTasksCache.containsKey(updated.projectId)) {
      _projectTasksCache[updated.projectId] =
          _projectTasksCache[updated.projectId]!
              .map((t) => t.id == taskId ? updated : t)
              .toList();
    }
    _myTasksCache.clear();

    return updated;
  }

  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async {
    final updated = await _remoteDataSource.updateTaskStatus(taskId, status);
    _taskDetailCache[taskId] = updated;

    if (_projectTasksCache.containsKey(updated.projectId)) {
      _projectTasksCache[updated.projectId] =
          _projectTasksCache[updated.projectId]!
              .map((t) => t.id == taskId ? updated : t)
              .toList();
    }
    _myTasksCache.clear();

    return updated;
  }

  @override
  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId) async {
    final updated = await _remoteDataSource.updateTaskAssignee(
      taskId,
      assigneeId,
    );
    _taskDetailCache[taskId] = updated;

    if (_projectTasksCache.containsKey(updated.projectId)) {
      _projectTasksCache[updated.projectId] =
          _projectTasksCache[updated.projectId]!
              .map((t) => t.id == taskId ? updated : t)
              .toList();
    }
    _myTasksCache.clear();

    return updated;
  }

  @override
  Future<void> deleteTask(int taskId) async {
    await _remoteDataSource.deleteTask(taskId);
    final cached = _taskDetailCache.remove(taskId);
    if (cached != null) {
      _projectTasksCache[cached.projectId]?.removeWhere((t) => t.id == taskId);
    } else {
      for (final list in _projectTasksCache.values) {
        list.removeWhere((t) => t.id == taskId);
      }
    }
    for (final list in _myTasksCache.values) {
      list.removeWhere((t) => t.id == taskId);
    }
  }

  @override
  bool hasCachedTasks(int projectId) =>
      _projectTasksCache.containsKey(projectId);
}
