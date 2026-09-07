import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/projects/data/models/project_status.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';

@injectable
class KanbanCubit extends SafeActionCubit<KanbanState> {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;

  int? _projectId;
  bool _isArchived = false;
  String? _searchFilter;
  String? _priorityFilter;
  String? _assigneeFilter;

  KanbanCubit(this._taskRepository, this._projectRepository)
    : super(const KanbanState.initial());

  int? get projectId => _projectId;
  bool get isArchived => _isArchived;
  String? get searchFilter => _searchFilter;
  String? get priorityFilter => _priorityFilter;
  String? get assigneeFilter => _assigneeFilter;

  Future<void> loadTasks(int projectId, {bool forceRefresh = false}) async {
    _projectId = projectId;
    emit(const KanbanState.loading());

    await safeExecute(
      () async {
        // Fetch project to determine archived state
        try {
          final project = await _projectRepository.getProject(
            projectId,
            forceRefresh: forceRefresh,
          );
          _isArchived = project.statusEnum == ProjectStatus.archived;
        } catch (_) {
          _isArchived = false;
        }

        final tasks = await _taskRepository.getTasksByProject(
          projectId,
          forceRefresh: forceRefresh,
        );

        if (tasks.isEmpty) {
          emit(
            KanbanState.empty(projectId: projectId, isArchived: _isArchived),
          );
        } else {
          final filtered = _applyFilters(tasks);
          emit(
            KanbanState.loaded(
              projectId: projectId,
              tasks: filtered,
              allTasks: tasks,
              isArchived: _isArchived,
              searchFilter: _searchFilter,
              priorityFilter: _priorityFilter,
              assigneeFilter: _assigneeFilter,
            ),
          );
        }
      },
      onError: (message) => emit(KanbanState.error(message)),
      defaultErrorMessage: 'Failed to load Kanban board',
      logTag: 'KanbanCubit',
    );
  }

  Future<void> refreshOnFocus() async {
    if (_projectId == null) return;
    final current = state;

    try {
      final tasks = await _taskRepository.getTasksByProject(
        _projectId!,
        forceRefresh: true,
      );

      if (tasks.isEmpty) {
        emit(
          KanbanState.empty(projectId: _projectId!, isArchived: _isArchived),
        );
      } else {
        final filtered = _applyFilters(tasks);
        emit(
          KanbanState.loaded(
            projectId: _projectId!,
            tasks: filtered,
            allTasks: tasks,
            isArchived: _isArchived,
            searchFilter: _searchFilter,
            priorityFilter: _priorityFilter,
            assigneeFilter: _assigneeFilter,
            errorMessage: current is KanbanLoaded ? current.errorMessage : null,
          ),
        );
      }
    } catch (_) {
      // On silent focus refresh failure, keep current view intact
    }
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

    // Optimistically update
    final optimisticTask = originalTask.copyWith(status: newStatus);
    final optimisticAll = List<TaskDto>.from(originalTasks);
    optimisticAll[taskIndex] = optimisticTask;

    emit(
      currentState.copyWith(
        allTasks: optimisticAll,
        tasks: _applyFilters(optimisticAll),
        errorMessage: null,
      ),
    );

    await safeExecute(
      () async {
        await _taskRepository.updateTaskStatus(taskId, newStatus);
      },
      onError: (errorMsg) {
        // Rollback to original state and notify user
        emit(
          currentState.copyWith(
            allTasks: originalTasks,
            tasks: _applyFilters(originalTasks),
            errorMessage: errorMsg.isNotEmpty
                ? errorMsg
                : 'Failed to move task. Reverted.',
          ),
        );
      },
      defaultErrorMessage: 'Failed to update task status',
      logTag: 'KanbanCubit',
    );
  }

  Future<TaskDto?> createTask(
    int projectId,
    CreateTaskRequest request, {
    String? initialStatus,
  }) async {
    if (_isArchived) return null;

    return await safeExecute<TaskDto>(
      () async {
        var created = await _taskRepository.createTask(projectId, request);

        if (initialStatus != null &&
            initialStatus.toLowerCase() != 'backlog' &&
            initialStatus.isNotEmpty) {
          created = await _taskRepository.updateTaskStatus(
            created.id,
            initialStatus,
          );
        }

        final currentState = state;
        List<TaskDto> updatedAll;
        if (currentState is KanbanLoaded) {
          updatedAll = [created, ...currentState.allTasks];
        } else {
          updatedAll = [created];
        }

        emit(
          KanbanState.loaded(
            projectId: projectId,
            tasks: _applyFilters(updatedAll),
            allTasks: updatedAll,
            isArchived: _isArchived,
            searchFilter: _searchFilter,
            priorityFilter: _priorityFilter,
            assigneeFilter: _assigneeFilter,
          ),
        );

        return created;
      },
      onError: (message) {
        final current = state;
        if (current is KanbanLoaded) {
          emit(current.copyWith(errorMessage: message));
        } else {
          emit(KanbanState.error(message));
        }
      },
      defaultErrorMessage: 'Failed to create task',
      logTag: 'KanbanCubit',
    );
  }

  Future<TaskDto?> updateTask(int taskId, UpdateTaskRequest request) async {
    if (_isArchived) return null;

    return await safeExecute<TaskDto>(
      () async {
        final updated = await _taskRepository.updateTask(taskId, request);
        final currentState = state;
        if (currentState is KanbanLoaded) {
          final updatedAll = currentState.allTasks
              .map((t) => t.id == taskId ? updated : t)
              .toList();
          emit(
            currentState.copyWith(
              allTasks: updatedAll,
              tasks: _applyFilters(updatedAll),
            ),
          );
        }
        return updated;
      },
      onError: (message) {
        final current = state;
        if (current is KanbanLoaded) {
          emit(current.copyWith(errorMessage: message));
        }
      },
      defaultErrorMessage: 'Failed to update task',
      logTag: 'KanbanCubit',
    );
  }

  Future<void> updateTaskAssignee(int taskId, String? assigneeId) async {
    if (_isArchived) return;

    await safeExecute(
      () async {
        final updated = await _taskRepository.updateTaskAssignee(
          taskId,
          assigneeId,
        );
        final currentState = state;
        if (currentState is KanbanLoaded) {
          final updatedAll = currentState.allTasks
              .map((t) => t.id == taskId ? updated : t)
              .toList();
          emit(
            currentState.copyWith(
              allTasks: updatedAll,
              tasks: _applyFilters(updatedAll),
            ),
          );
        }
      },
      onError: (message) {
        final current = state;
        if (current is KanbanLoaded) {
          emit(current.copyWith(errorMessage: message));
        }
      },
      defaultErrorMessage: 'Failed to reassign task',
      logTag: 'KanbanCubit',
    );
  }

  Future<void> deleteTask(int taskId) async {
    if (_isArchived) return;

    await safeExecute(
      () async {
        await _taskRepository.deleteTask(taskId);
        final currentState = state;
        if (currentState is KanbanLoaded) {
          final updatedAll = currentState.allTasks
              .where((t) => t.id != taskId)
              .toList();

          if (updatedAll.isEmpty) {
            emit(
              KanbanState.empty(
                projectId: currentState.projectId,
                isArchived: _isArchived,
              ),
            );
          } else {
            emit(
              currentState.copyWith(
                allTasks: updatedAll,
                tasks: _applyFilters(updatedAll),
              ),
            );
          }
        }
      },
      onError: (message) {
        final current = state;
        if (current is KanbanLoaded) {
          emit(current.copyWith(errorMessage: message));
        }
      },
      defaultErrorMessage: 'Failed to delete task',
      logTag: 'KanbanCubit',
    );
  }

  void setFilter({
    String? search,
    String? priority,
    String? assigneeId,
    bool clearSearch = false,
    bool clearPriority = false,
    bool clearAssignee = false,
  }) {
    if (clearSearch) {
      _searchFilter = null;
    } else if (search != null) {
      _searchFilter = search.trim().isEmpty ? null : search.trim();
    }

    if (clearPriority) {
      _priorityFilter = null;
    } else if (priority != null) {
      _priorityFilter = priority.toLowerCase() == 'all' ? null : priority;
    }

    if (clearAssignee) {
      _assigneeFilter = null;
    } else if (assigneeId != null) {
      _assigneeFilter = assigneeId.toLowerCase() == 'all' ? null : assigneeId;
    }

    final currentState = state;
    if (currentState is KanbanLoaded) {
      emit(
        currentState.copyWith(
          tasks: _applyFilters(currentState.allTasks),
          searchFilter: _searchFilter,
          priorityFilter: _priorityFilter,
          assigneeFilter: _assigneeFilter,
        ),
      );
    }
  }

  void clearFilters() {
    _searchFilter = null;
    _priorityFilter = null;
    _assigneeFilter = null;

    final currentState = state;
    if (currentState is KanbanLoaded) {
      emit(
        currentState.copyWith(
          tasks: currentState.allTasks,
          searchFilter: null,
          priorityFilter: null,
          assigneeFilter: null,
        ),
      );
    }
  }

  void clearErrorMessage() {
    final current = state;
    if (current is KanbanLoaded && current.errorMessage != null) {
      emit(current.copyWith(errorMessage: null));
    }
  }

  List<TaskDto> _applyFilters(List<TaskDto> tasks) {
    return tasks.where((task) {
      if (_searchFilter != null && _searchFilter!.isNotEmpty) {
        final query = _searchFilter!.toLowerCase();
        final matchesTitle = task.title.toLowerCase().contains(query);
        final matchesDesc = task.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesDesc) return false;
      }

      if (_priorityFilter != null && _priorityFilter!.isNotEmpty) {
        if (task.priority.toLowerCase() != _priorityFilter!.toLowerCase()) {
          return false;
        }
      }

      if (_assigneeFilter != null && _assigneeFilter!.isNotEmpty) {
        if (_assigneeFilter == 'unassigned') {
          if (task.assigneeId != null && task.assigneeId!.isNotEmpty) {
            return false;
          }
        } else {
          if (task.assigneeId != _assigneeFilter) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }
}
