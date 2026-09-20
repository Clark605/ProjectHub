import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

abstract class TagRemoteDataSource {
  Future<TagDto> createWorkspaceTag(int workspaceId, String name);
  Future<TagDto> createProjectTag(int projectId, String name);
  Future<List<TagDto>> getAvailableTagsForProject(int projectId);
  Future<List<TagDto>> getWorkspaceTags(int workspaceId);
  Future<TaskDto> attachTagToTask(int taskId, int tagId);
  Future<TaskDto> detachTagFromTask(int taskId, int tagId);
  Future<void> deleteTag(int tagId);
}

@LazySingleton(as: TagRemoteDataSource)
class TagRemoteDataSourceImpl implements TagRemoteDataSource {
  TagRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  Future<T> _guard<T>(String op, Future<T> Function() call) async {
    try {
      AppLogger.info(op, tag: 'TagRemoteDataSource');
      final result = await call();
      AppLogger.debug('Success: $op', tag: 'TagRemoteDataSource');
      return result;
    } on DioException catch (e) {
      AppLogger.error('Failed: $op', error: e, tag: 'TagRemoteDataSource');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<TagDto> createWorkspaceTag(int workspaceId, String name) {
    return _guard('Creating workspace tag: $name', () async {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.workspaceTags(workspaceId),
        data: {'name': name},
      );
      return TagDto.fromJson(res.data!);
    });
  }

  @override
  Future<TagDto> createProjectTag(int projectId, String name) {
    return _guard('Creating project tag: $name', () async {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.projectTags(projectId),
        data: {'name': name},
      );
      return TagDto.fromJson(res.data!);
    });
  }

  @override
  Future<List<TagDto>> getAvailableTagsForProject(int projectId) {
    return _guard('Fetching available tags for project $projectId', () async {
      final res = await _dio.get<List<dynamic>>(
        ApiConstants.projectAvailableTags(projectId),
      );
      return (res.data ?? [])
          .map((e) => TagDto.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<List<TagDto>> getWorkspaceTags(int workspaceId) {
    return _guard('Fetching workspace tags for workspace $workspaceId', () async {
      final res = await _dio.get<List<dynamic>>(
        ApiConstants.workspaceTags(workspaceId),
      );
      return (res.data ?? [])
          .map((e) => TagDto.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<TaskDto> attachTagToTask(int taskId, int tagId) {
    return _guard('Attaching tag $tagId to task $taskId', () async {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.taskTags(taskId),
        data: {'tagId': tagId},
      );
      return TaskDto.fromJson(res.data!);
    });
  }

  @override
  Future<TaskDto> detachTagFromTask(int taskId, int tagId) {
    return _guard('Detaching tag $tagId from task $taskId', () async {
      final res = await _dio.delete<Map<String, dynamic>>(
        ApiConstants.taskTag(taskId, tagId),
      );
      return TaskDto.fromJson(res.data!);
    });
  }

  @override
  Future<void> deleteTag(int tagId) {
    return _guard('Deleting tag $tagId', () async {
      await _dio.delete<void>(ApiConstants.tagById(tagId));
    });
  }
}
