import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

abstract class TagRepository {
  Future<TagDto> createWorkspaceTag(int workspaceId, String name);
  Future<TagDto> createProjectTag(int projectId, String name);
  Future<List<TagDto>> getAvailableTagsForProject(int projectId);
  Future<List<TagDto>> getWorkspaceTags(int workspaceId);
  Future<TaskDto> attachTagToTask(int taskId, int tagId);
  Future<TaskDto> detachTagFromTask(int taskId, int tagId);
  Future<void> deleteTag(int tagId);
}
