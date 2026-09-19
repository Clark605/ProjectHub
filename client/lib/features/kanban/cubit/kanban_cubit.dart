import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_filter_mixin.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/projects/data/models/project_status.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';

@injectable
class KanbanCubit extends SafeActionCubit<KanbanState> with KanbanFilterMixin {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;

  int? _projectId;
  bool _isArchived = false;

  KanbanCubit(this._taskRepository, this._projectRepository)
      : super(const KanbanState.initial());

  int? get projectId => _projectId;
  bool get isArchived => _isArchived;

  void _emitLoaded(List<TaskDto> allTasks, {String? errorMessage}) {
    emit(KanbanState.loaded(
      projectId: _projectId ?? 0,
      tasks: applyFilters(allTasks),
      allTasks: allTasks,
      isArchived: _isArchived,
      searchFilter: searchFilter,
      priorityFilter: priorityFilter,
      assigneeFilter: assigneeFilter,
      errorMessage: errorMessage,
    ));
  }

  @override
  void onFiltersUpdated() {
    final current = state;
    if (current is KanbanLoaded) _emitLoaded(current.allTasks);
  }

  Future<void> loadTasks(int projectId, {bool forceRefresh = false}) async {
    _projectId = projectId;
    emit(const KanbanState.loading());

    await safeExecute(
      () async {
        try {
          final p = await _projectRepository.getProject(projectId, forceRefresh: forceRefresh);
          _isArchived = p.statusEnum == ProjectStatus.archived;
        } catch (_) {
          _isArchived = false;
        }

        final tasks = await _taskRepository.getTasksByProject(projectId, forceRefresh: forceRefresh);
        if (tasks.isEmpty) {
          emit(KanbanState.empty(projectId: projectId, isArchived: _isArchived));
        } else {
          _emitLoaded(tasks);
        }
      },
      onError: (message) => emit(KanbanState.error(message)),
      defaultErrorMessage: 'Failed to load Kanban board',
      logTag: 'KanbanCubit',
    );
  }

  Future<void> refreshOnFocus() async {
    if (_projectId == null) return;
    try {
      final tasks = await _taskRepository.getTasksByProject(_projectId!, forceRefresh: true);
      if (tasks.isEmpty) {
        emit(KanbanState.empty(projectId: _projectId!, isArchived: _isArchived));
      } else {
        final current = state;
        _emitLoaded(tasks, errorMessage: current is KanbanLoaded ? current.errorMessage : null);
      }
    } catch (_) {}
  }

  Future<void> moveTaskStatus(int taskId, String newStatus) async {
    if (_isArchived) return;
    final currentState = state;
    if (currentState is! KanbanLoaded) return;

    final originalTasks = currentState.allTasks;
    final taskIndex = originalTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;

    final originalTask = originalTasks[taskIndex];
    if (originalTask.status.toLowerCase() == newStatus.toLowerCase()) return;

    final optimisticAll = List<TaskDto>.from(originalTasks);
    optimisticAll[taskIndex] = originalTask.copyWith(status: newStatus);
    _emitLoaded(optimisticAll);

    await safeExecute(
      () async => _taskRepository.updateTaskStatus(taskId, newStatus),
      onError: (errorMsg) {
        final latest = state is KanbanLoaded ? (state as KanbanLoaded).allTasks : originalTasks;
        final rollbackAll = latest.map((t) => t.id == taskId ? t.copyWith(status: originalTask.status) : t).toList();
        _emitLoaded(rollbackAll, errorMessage: errorMsg.isNotEmpty ? errorMsg : 'Failed to move task. Reverted.');
      },
      defaultErrorMessage: 'Failed to update task status',
      logTag: 'KanbanCubit',
    );
  }

  Future<TaskDto?> createTask(int projectId, CreateTaskRequest req, {String? initialStatus}) async {
    if (_isArchived) return null;
    return await safeExecute<TaskDto>(
      () async {
        var created = await _taskRepository.createTask(projectId, req);
        if (initialStatus != null && initialStatus.toLowerCase() != 'backlog' && initialStatus.isNotEmpty) {
          created = await _taskRepository.updateTaskStatus(created.id, initialStatus);
        }
        final current = state;
        _emitLoaded(current is KanbanLoaded ? [created, ...current.allTasks] : [created]);
        return created;
      },
      onError: (msg) => _setLoadedError(msg),
      defaultErrorMessage: 'Failed to create task',
      logTag: 'KanbanCubit',
    );
  }

  Future<TaskDto?> updateTask(int taskId, UpdateTaskRequest request) async {
    if (_isArchived) return null;
    return await safeExecute<TaskDto>(
      () async {
        final updated = await _taskRepository.updateTask(taskId, request);
        _updateTaskInLoaded(taskId, updated);
        return updated;
      },
      onError: (msg) => _setLoadedError(msg),
      defaultErrorMessage: 'Failed to update task',
      logTag: 'KanbanCubit',
    );
  }

  Future<void> updateTaskAssignee(int taskId, String? assigneeId) async {
    if (_isArchived) return;
    await safeExecute(
      () async {
        final updated = await _taskRepository.updateTaskAssignee(taskId, assigneeId);
        _updateTaskInLoaded(taskId, updated);
      },
      onError: (msg) => _setLoadedError(msg),
      defaultErrorMessage: 'Failed to reassign task',
      logTag: 'KanbanCubit',
    );
  }

  Future<void> deleteTask(int taskId) async {
    if (_isArchived) return;
    await safeExecute(
      () async {
        await _taskRepository.deleteTask(taskId);
        final current = state;
        if (current is KanbanLoaded) {
          final updatedAll = current.allTasks.where((t) => t.id != taskId).toList();
          if (updatedAll.isEmpty) {
            emit(KanbanState.empty(projectId: current.projectId, isArchived: _isArchived));
          } else {
            _emitLoaded(updatedAll);
          }
        }
      },
      onError: (msg) => _setLoadedError(msg),
      defaultErrorMessage: 'Failed to delete task',
      logTag: 'KanbanCubit',
    );
  }

  void _updateTaskInLoaded(int taskId, TaskDto updated) {
    final current = state;
    if (current is KanbanLoaded) {
      _emitLoaded(current.allTasks.map((t) => t.id == taskId ? updated : t).toList());
    }
  }

  void _setLoadedError(String msg) {
    final current = state;
    if (current is KanbanLoaded) emit(current.copyWith(errorMessage: msg));
  }

  void clearErrorMessage() {
    final current = state;
    if (current is KanbanLoaded && current.errorMessage != null) {
      emit(current.copyWith(errorMessage: null));
    }
  }
}
