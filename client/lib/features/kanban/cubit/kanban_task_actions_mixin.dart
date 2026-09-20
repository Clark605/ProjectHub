import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';

mixin KanbanTaskActionsMixin on SafeActionCubit<KanbanState> {
  TaskRepository get taskRepository;
  bool get isArchived;
  void emitLoaded(List<TaskDto> allTasks, {String? errorMessage});
  void updateTaskInLoaded(int taskId, TaskDto updated);
  void setLoadedError(String msg);

  Future<void> moveTaskStatus(int taskId, String newStatus) async {
    if (isArchived) return;
    final currentState = state;
    if (currentState is! KanbanLoaded) return;

    final originalTasks = currentState.allTasks;
    final taskIndex = originalTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final originalTask = originalTasks[taskIndex];
    if (originalTask.status.toLowerCase() == newStatus.toLowerCase()) return;

    final optimisticAll = List<TaskDto>.from(originalTasks);
    optimisticAll[taskIndex] = originalTask.copyWith(status: newStatus);
    emitLoaded(optimisticAll);

    await safeExecute(
      () async => taskRepository.updateTaskStatus(taskId, newStatus),
      onError: (errorMsg) {
        final latest = state is KanbanLoaded ? (state as KanbanLoaded).allTasks : originalTasks;
        final rollbackAll = latest
            .map((t) => t.id == taskId ? t.copyWith(status: originalTask.status) : t)
            .toList();
        emitLoaded(
          rollbackAll,
          errorMessage: errorMsg.isNotEmpty ? errorMsg : 'Failed to move task. Reverted.',
        );
      },
      defaultErrorMessage: 'Failed to update task status',
      logTag: 'KanbanCubit',
    );
  }

  Future<TaskDto?> createTask(
    int projectId,
    CreateTaskRequest req, {
    String? initialStatus,
  }) async {
    if (isArchived) return null;
    return await safeExecute<TaskDto>(
      () async {
        var created = await taskRepository.createTask(projectId, req);
        if (initialStatus != null &&
            initialStatus.toLowerCase() != 'backlog' &&
            initialStatus.isNotEmpty) {
          created = await taskRepository.updateTaskStatus(created.id, initialStatus);
        }
        final current = state;
        emitLoaded(current is KanbanLoaded ? [created, ...current.allTasks] : [created]);
        return created;
      },
      onError: (msg) => setLoadedError(msg),
      defaultErrorMessage: 'Failed to create task',
      logTag: 'KanbanCubit',
    );
  }

  Future<TaskDto?> updateTask(int taskId, UpdateTaskRequest request) async {
    if (isArchived) return null;
    return await safeExecute<TaskDto>(
      () async {
        final updated = await taskRepository.updateTask(taskId, request);
        updateTaskInLoaded(taskId, updated);
        return updated;
      },
      onError: (msg) => setLoadedError(msg),
      defaultErrorMessage: 'Failed to update task',
      logTag: 'KanbanCubit',
    );
  }

  Future<void> updateTaskAssignee(int taskId, String? assigneeId) async {
    if (isArchived) return;
    await safeExecute(
      () async {
        final updated = await taskRepository.updateTaskAssignee(taskId, assigneeId);
        updateTaskInLoaded(taskId, updated);
      },
      onError: (msg) => setLoadedError(msg),
      defaultErrorMessage: 'Failed to reassign task',
      logTag: 'KanbanCubit',
    );
  }

  Future<void> deleteTask(int taskId) async {
    if (isArchived) return;
    await safeExecute(
      () async {
        await taskRepository.deleteTask(taskId);
        final current = state;
        if (current is KanbanLoaded) {
          final updatedAll = current.allTasks.where((t) => t.id != taskId).toList();
          if (updatedAll.isEmpty) {
            emit(KanbanState.empty(projectId: current.projectId, isArchived: isArchived));
          } else {
            emitLoaded(updatedAll);
          }
        }
      },
      onError: (msg) => setLoadedError(msg),
      defaultErrorMessage: 'Failed to delete task',
      logTag: 'KanbanCubit',
    );
  }
}
