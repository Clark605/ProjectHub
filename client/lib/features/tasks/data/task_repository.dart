import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';

abstract class TaskRepository {
  void clearCache([int? projectId]);

  Future<List<TaskDto>> getTasksByProject(
    int projectId, {
    String? status,
    String? assigneeId,
    String? priority,
    bool forceRefresh = false,
  });

  Future<List<TaskDto>> getMyTasks(
    int workspaceId, {
    bool forceRefresh = false,
  });

  Future<TaskDto> getTask(int taskId, {bool forceRefresh = false});

  Future<TaskDto> createTask(int projectId, CreateTaskRequest request);

  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request);

  Future<TaskDto> updateTaskStatus(int taskId, String status);

  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId);

  Future<void> deleteTask(int taskId);

  bool hasCachedTasks(int projectId);
}
