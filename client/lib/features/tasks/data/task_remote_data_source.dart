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

  Future<T> _guard<T>(String op, Future<T> Function() call) async {
    try {
      AppLogger.info(op, tag: 'TaskRemoteDataSource');
      final result = await call();
      AppLogger.debug('Success: $op', tag: 'TaskRemoteDataSource');
      return result;
    } on DioException catch (e) {
      AppLogger.error('Failed: $op', error: e, tag: 'TaskRemoteDataSource');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<List<TaskDto>> getTasksByProject(
    int projectId, {
    String? status,
    String? assigneeId,
    String? priority,
  }) {
    return _guard('Fetching tasks for project $projectId', () async {
      final q = <String, dynamic>{};
      if (status != null &&
          status.isNotEmpty &&
          status.toLowerCase() != 'all') {
        q['status'] = status;
      }
      if (assigneeId != null && assigneeId.isNotEmpty) {
        q['assigneeId'] = assigneeId;
      }
      if (priority != null &&
          priority.isNotEmpty &&
          priority.toLowerCase() != 'all') {
        q['priority'] = priority;
      }

      final res = await _dio.get(
        ApiConstants.projectTasks(projectId),
        queryParameters: q.isNotEmpty ? q : null,
      );
      return (res.data as List)
          .map((i) => TaskDto.fromJson(i as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<List<TaskDto>> getMyTasks(int workspaceId) {
    return _guard('Fetching my tasks for workspace $workspaceId', () async {
      final res = await _dio.get(ApiConstants.workspaceMyTasks(workspaceId));
      return (res.data as List)
          .map((i) => TaskDto.fromJson(i as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<TaskDto> getTask(int taskId) {
    return _guard('Fetching task $taskId', () async {
      final res = await _dio.get(ApiConstants.taskById(taskId));
      return TaskDto.fromJson(res.data as Map<String, dynamic>);
    });
  }

  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) {
    return _guard('Creating task in project $projectId', () async {
      final res = await _dio.post(
        ApiConstants.projectTasks(projectId),
        data: request.toJson(),
      );
      return TaskDto.fromJson(res.data as Map<String, dynamic>);
    });
  }

  @override
  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request) {
    return _guard('Updating task $taskId', () async {
      final res = await _dio.put(
        ApiConstants.taskById(taskId),
        data: request.toJson(),
      );
      return TaskDto.fromJson(res.data as Map<String, dynamic>);
    });
  }

  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) {
    return _guard('Updating status of task $taskId to $status', () async {
      final res = await _dio.patch(
        ApiConstants.taskStatus(taskId),
        data: {'status': status},
      );
      return TaskDto.fromJson(res.data as Map<String, dynamic>);
    });
  }

  @override
  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId) {
    return _guard('Updating assignee of task $taskId to $assigneeId', () async {
      final res = await _dio.patch(
        ApiConstants.taskAssignee(taskId),
        data: {'assigneeId': assigneeId},
      );
      return TaskDto.fromJson(res.data as Map<String, dynamic>);
    });
  }

  @override
  Future<void> deleteTask(int taskId) {
    return _guard('Deleting task $taskId', () async {
      await _dio.delete(ApiConstants.taskById(taskId));
    });
  }
}
