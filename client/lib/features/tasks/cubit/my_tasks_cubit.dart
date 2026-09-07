import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/tasks/cubit/my_tasks_state.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';

@injectable
class MyTasksCubit extends SafeActionCubit<MyTasksState> {
  final TaskRepository _taskRepository;
  int? _workspaceId;
  bool _showDone = false;

  MyTasksCubit(this._taskRepository) : super(const MyTasksState.initial());

  int? get workspaceId => _workspaceId;
  bool get showDone => _showDone;

  Future<void> loadMyTasks(int workspaceId, {bool forceRefresh = false}) async {
    _workspaceId = workspaceId;
    emit(const MyTasksState.loading());

    await safeExecute(
      () async {
        final tasks = await _taskRepository.getMyTasks(
          workspaceId,
          forceRefresh: forceRefresh,
        );

        if (tasks.isEmpty) {
          emit(MyTasksState.empty(workspaceId: workspaceId));
          return;
        }

        _emitGroupedTasks(workspaceId, tasks);
      },
      onError: (message) => emit(MyTasksState.error(message)),
      defaultErrorMessage: 'Failed to load My Tasks',
      logTag: 'MyTasksCubit',
    );
  }

  Future<void> refreshOnFocus() async {
    if (_workspaceId == null) return;

    try {
      final tasks = await _taskRepository.getMyTasks(
        _workspaceId!,
        forceRefresh: true,
      );

      if (tasks.isEmpty) {
        emit(MyTasksState.empty(workspaceId: _workspaceId!));
      } else {
        _emitGroupedTasks(_workspaceId!, tasks);
      }
    } catch (_) {
      // Keep view intact on silent background refresh failure
    }
  }

  void toggleDoneVisibility() {
    _showDone = !_showDone;
    final current = state;
    if (current is MyTasksLoaded) {
      emit(current.copyWith(showDone: _showDone));
    }
  }

  Future<void> updateTaskStatus(int taskId, String newStatus) async {
    await safeExecute(
      () async {
        await _taskRepository.updateTaskStatus(taskId, newStatus);
        if (_workspaceId != null) {
          final tasks = await _taskRepository.getMyTasks(
            _workspaceId!,
            forceRefresh: true,
          );
          _emitGroupedTasks(_workspaceId!, tasks);
        }
      },
      onError: (message) {
        final current = state;
        if (current is MyTasksLoaded) {
          emit(current.copyWith(errorMessage: message));
        }
      },
      defaultErrorMessage: 'Failed to update task status',
      logTag: 'MyTasksCubit',
    );
  }

  Future<void> updateTask(int taskId, UpdateTaskRequest request) async {
    await safeExecute(
      () async {
        await _taskRepository.updateTask(taskId, request);
        if (_workspaceId != null) {
          final tasks = await _taskRepository.getMyTasks(
            _workspaceId!,
            forceRefresh: true,
          );
          _emitGroupedTasks(_workspaceId!, tasks);
        }
      },
      onError: (message) {
        final current = state;
        if (current is MyTasksLoaded) {
          emit(current.copyWith(errorMessage: message));
        }
      },
      defaultErrorMessage: 'Failed to update task',
      logTag: 'MyTasksCubit',
    );
  }

  Future<void> deleteTask(int taskId) async {
    await safeExecute(
      () async {
        await _taskRepository.deleteTask(taskId);
        if (_workspaceId != null) {
          final tasks = await _taskRepository.getMyTasks(
            _workspaceId!,
            forceRefresh: true,
          );
          if (tasks.isEmpty) {
            emit(MyTasksState.empty(workspaceId: _workspaceId!));
          } else {
            _emitGroupedTasks(_workspaceId!, tasks);
          }
        }
      },
      onError: (message) {
        final current = state;
        if (current is MyTasksLoaded) {
          emit(current.copyWith(errorMessage: message));
        }
      },
      defaultErrorMessage: 'Failed to delete task',
      logTag: 'MyTasksCubit',
    );
  }

  void _emitGroupedTasks(int workspaceId, List<TaskDto> allTasks) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final urgent = <TaskDto>[];
    final inProgress = <TaskDto>[];
    final todo = <TaskDto>[];
    final done = <TaskDto>[];

    for (final task in allTasks) {
      if (task.statusEnum == TaskStatus.done) {
        // Show tasks completed within the last 7 days (or without updatedAt)
        if (task.updatedAt == null || task.updatedAt!.isAfter(sevenDaysAgo)) {
          done.add(task);
        }
      } else if (task.priorityEnum == TaskPriority.urgent || task.isOverdue) {
        urgent.add(task);
      } else if (task.statusEnum == TaskStatus.inProgress) {
        inProgress.add(task);
      } else {
        todo.add(task);
      }
    }

    emit(
      MyTasksState.loaded(
        workspaceId: workspaceId,
        urgentTasks: urgent,
        inProgressTasks: inProgress,
        todoTasks: todo,
        doneTasks: done,
        showDone: _showDone,
      ),
    );
  }
}
