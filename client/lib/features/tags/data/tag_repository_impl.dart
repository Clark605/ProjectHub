import 'package:injectable/injectable.dart';

import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tags/data/tag_remote_data_source.dart';
import 'package:client/features/tags/data/tag_repository.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

@LazySingleton(as: TagRepository)
class TagRepositoryImpl implements TagRepository {
  TagRepositoryImpl(this._remoteDataSource);

  final TagRemoteDataSource _remoteDataSource;

  @override
  Future<TagDto> createWorkspaceTag(int workspaceId, String name) =>
      _remoteDataSource.createWorkspaceTag(workspaceId, name);

  @override
  Future<TagDto> createProjectTag(int projectId, String name) =>
      _remoteDataSource.createProjectTag(projectId, name);

  @override
  Future<List<TagDto>> getAvailableTagsForProject(int projectId) =>
      _remoteDataSource.getAvailableTagsForProject(projectId);

  @override
  Future<List<TagDto>> getWorkspaceTags(int workspaceId) =>
      _remoteDataSource.getWorkspaceTags(workspaceId);

  @override
  Future<TaskDto> attachTagToTask(int taskId, int tagId) =>
      _remoteDataSource.attachTagToTask(taskId, tagId);

  @override
  Future<TaskDto> detachTagFromTask(int taskId, int tagId) =>
      _remoteDataSource.detachTagFromTask(taskId, tagId);

  @override
  Future<void> deleteTag(int tagId) => _remoteDataSource.deleteTag(tagId);
}
