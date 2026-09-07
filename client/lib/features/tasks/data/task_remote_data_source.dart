import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskDto>> getTasksByProject(
    int projectId, {
    String? status,
    String? assigneeId,
    String? priority,
  });

  Future<List<TaskDto>> getMyTasks(int workspaceId);

  Future<TaskDto> getTask(int taskId);

  Future<TaskDto> createTask(int projectId, CreateTaskRequest request);

  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request);

  Future<TaskDto> updateTaskStatus(int taskId, String status);

  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId);

  Future<void> deleteTask(int taskId);
}

@LazySingleton(as: TaskRemoteDataSource)
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio _dio;

  TaskRemoteDataSourceImpl(this._dio);

  @override
  Future<List<TaskDto>> getTasksByProject(
    int projectId, {
    String? status,
    String? assigneeId,
    String? priority,
  }) async {
    try {
      AppLogger.info(
        'Fetching tasks for project $projectId',
        tag: 'TaskRemoteDataSource',
      );
      final queryParams = <String, dynamic>{};
      if (status != null &&
          status.isNotEmpty &&
          status.toLowerCase() != 'all') {
        queryParams['status'] = status;
      }
      if (assigneeId != null && assigneeId.isNotEmpty) {
        queryParams['assigneeId'] = assigneeId;
      }
      if (priority != null &&
          priority.isNotEmpty &&
          priority.toLowerCase() != 'all') {
        queryParams['priority'] = priority;
      }

      final response = await _dio.get(
        ApiConstants.projectTasks(projectId),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final list = (response.data as List)
          .map((item) => TaskDto.fromJson(item as Map<String, dynamic>))
          .toList();

      AppLogger.debug(
        'Fetched ${list.length} tasks for project $projectId',
        tag: 'TaskRemoteDataSource',
      );
      return list;
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to fetch tasks for project $projectId',
        error: e,
        tag: 'TaskRemoteDataSource',
      );
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<List<TaskDto>> getMyTasks(int workspaceId) async {
    try {
      AppLogger.info(
        'Fetching my tasks for workspace $workspaceId',
        tag: 'TaskRemoteDataSource',
      );
      final response = await _dio.get(
        ApiConstants.workspaceMyTasks(workspaceId),
      );
      final list = (response.data as List)
          .map((item) => TaskDto.fromJson(item as Map<String, dynamic>))
          .toList();

      AppLogger.debug(
        'Fetched ${list.length} my tasks for workspace $workspaceId',
        tag: 'TaskRemoteDataSource',
      );
      return list;
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to fetch my tasks for workspace $workspaceId',
        error: e,
        tag: 'TaskRemoteDataSource',
      );
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<TaskDto> getTask(int taskId) async {
    try {
      AppLogger.info('Fetching task $taskId', tag: 'TaskRemoteDataSource');
      final response = await _dio.get(ApiConstants.taskById(taskId));
      return TaskDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to fetch task $taskId',
        error: e,
        tag: 'TaskRemoteDataSource',
      );
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async {
    try {
      AppLogger.info(
        'Creating task in project $projectId',
        tag: 'TaskRemoteDataSource',
      );
      final response = await _dio.post(
        ApiConstants.projectTasks(projectId),
        data: request.toJson(),
      );
      final created = TaskDto.fromJson(response.data as Map<String, dynamic>);
      AppLogger.debug(
        'Created task ${created.id}',
        tag: 'TaskRemoteDataSource',
      );
      return created;
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to create task in project $projectId',
        error: e,
        tag: 'TaskRemoteDataSource',
      );
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request) async {
    try {
      AppLogger.info('Updating task $taskId', tag: 'TaskRemoteDataSource');
      final response = await _dio.put(
        ApiConstants.taskById(taskId),
        data: request.toJson(),
      );
      final updated = TaskDto.fromJson(response.data as Map<String, dynamic>);
      AppLogger.debug('Updated task $taskId', tag: 'TaskRemoteDataSource');
      return updated;
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to update task $taskId',
        error: e,
        tag: 'TaskRemoteDataSource',
      );
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async {
    try {
      AppLogger.info(
        'Updating status of task $taskId to $status',
        tag: 'TaskRemoteDataSource',
      );
      final response = await _dio.patch(
        ApiConstants.taskStatus(taskId),
        data: {'status': status},
      );
      final updated = TaskDto.fromJson(response.data as Map<String, dynamic>);
      AppLogger.debug(
        'Updated task $taskId status to $status',
        tag: 'TaskRemoteDataSource',
      );
      return updated;
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to update status of task $taskId',
        error: e,
        tag: 'TaskRemoteDataSource',
      );
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId) async {
    try {
      AppLogger.info(
        'Updating assignee of task $taskId to $assigneeId',
        tag: 'TaskRemoteDataSource',
      );
      final response = await _dio.patch(
        ApiConstants.taskAssignee(taskId),
        data: {'assigneeId': assigneeId},
      );
      final updated = TaskDto.fromJson(response.data as Map<String, dynamic>);
      AppLogger.debug(
        'Updated task $taskId assignee to $assigneeId',
        tag: 'TaskRemoteDataSource',
      );
      return updated;
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to update assignee of task $taskId',
        error: e,
        tag: 'TaskRemoteDataSource',
      );
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteTask(int taskId) async {
    try {
      AppLogger.info('Deleting task $taskId', tag: 'TaskRemoteDataSource');
      await _dio.delete(ApiConstants.taskById(taskId));
      AppLogger.debug('Deleted task $taskId', tag: 'TaskRemoteDataSource');
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to delete task $taskId',
        error: e,
        tag: 'TaskRemoteDataSource',
      );
      throw DioErrorHandler.handle(e);
    }
  }
}
