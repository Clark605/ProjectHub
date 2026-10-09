import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_filter.dart';
import 'package:client/features/tasks/data/task_repository.dart';

mixin KanbanTaskActionsMixin on SafeActionCubit<KanbanState> {
  TaskRepository get taskRepository;
  bool get isArchived;
  void emitLoaded(
    List<TaskDto> allTasks, {
    TaskFilter? filter,
    String? errorMessage,
  });
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
        final latest = state is KanbanLoaded
            ? (state as KanbanLoaded).allTasks
            : originalTasks;
        final rollbackAll = latest
            .map(
              (t) =>
                  t.id == taskId ? t.copyWith(status: originalTask.status) : t,
            )
            .toList();
        emitLoaded(
          rollbackAll,
          errorMessage: errorMsg.isNotEmpty
              ? errorMsg
              : 'Failed to move task. Reverted.',
        );
      },
      defaultErrorMessage: 'Failed to update task status',
      logTag: 'KanbanCubit',
    );
  }

  Future<TaskDto> createTask(
    int projectId,
    CreateTaskRequest req, {
    String? initialStatus,
  }) async {
    if (isArchived) {
      throw const AppException(
        message: 'Cannot create tasks in an archived project',
      );
    }

    final targetStatus = initialStatus ?? req.status;
    final requestWithStatus =
        (targetStatus != null &&
            targetStatus.isNotEmpty &&
            req.status != targetStatus)
        ? req.copyWith(status: targetStatus)
        : req;

    TaskDto created;
    try {
      created = await taskRepository.createTask(projectId, requestWithStatus);
    } on AppException catch (e) {
      setLoadedError(e.message);
      rethrow;
    } on Object catch (_) {
      // Fallback error message when non-AppException is encountered
      setLoadedError('Failed to create task');
      rethrow;
    }

    // Fallback if backend didn't set target status or if initialStatus differs:
    if (targetStatus != null &&
        targetStatus.toLowerCase() != 'backlog' &&
        targetStatus.isNotEmpty &&
        created.status.toLowerCase() != targetStatus.toLowerCase()) {
      try {
        created = await taskRepository.updateTaskStatus(
          created.id,
          targetStatus,
        );
      } on Object catch (e) {
        // H3: Even if status update fails, emit the created task in state!
        final errorMsg = e is AppException
            ? e.message
            : 'Task created, but failed to set status';
        _insertTaskIntoState(created, errorMessage: errorMsg);
        rethrow;
      }
    }

    _insertTaskIntoState(created);
    return created;
  }

  void _insertTaskIntoState(TaskDto task, {String? errorMessage}) {
    final current = state;
    if (current is KanbanLoaded) {
      final existingIndex = current.allTasks.indexWhere((t) => t.id == task.id);
      final updatedAll = existingIndex != -1
          ? (List<TaskDto>.from(current.allTasks)..[existingIndex] = task)
          : [task, ...current.allTasks];
      emitLoaded(updatedAll, errorMessage: errorMessage);
    } else {
      emitLoaded([task], errorMessage: errorMessage);
    }
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
        final updated = await taskRepository.updateTaskAssignee(
          taskId,
          assigneeId,
        );
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
          final updatedAll = current.allTasks
              .where((t) => t.id != taskId)
              .toList();
          if (updatedAll.isEmpty) {
            emit(
              KanbanState.empty(
                projectId: current.projectId,
                isArchived: isArchived,
              ),
            );
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
