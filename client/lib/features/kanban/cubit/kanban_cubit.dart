import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/features/kanban/cubit/kanban_filter_mixin.dart';
import 'package:client/features/kanban/cubit/kanban_realtime_mixin.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/kanban/cubit/kanban_task_actions_mixin.dart';
import 'package:client/features/projects/data/models/project_status.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/task_repository.dart';

@injectable
class KanbanCubit extends SafeActionCubit<KanbanState>
    with KanbanFilterMixin, KanbanRealtimeMixin, KanbanTaskActionsMixin {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final SignalRService? _signalRService;

  int? _projectId;
  int? _workspaceId;
  bool _isArchived = false;

  KanbanCubit(
    this._taskRepository,
    this._projectRepository, [
    this._signalRService,
  ]) : super(const KanbanState.initial());

  @override
  TaskRepository get taskRepository => _taskRepository;
  @override
  SignalRService? get signalRService => _signalRService;
  @override
  int? get currentProjectId => _projectId;
  @override
  bool get isArchived => _isArchived;
  int? get projectId => _projectId;

  @override
  void emitLoaded(List<TaskDto> allTasks, {String? errorMessage}) {
    emit(
      KanbanState.loaded(
        projectId: _projectId ?? 0,
        tasks: applyFilters(allTasks),
        allTasks: allTasks,
        isArchived: _isArchived,
        searchFilter: searchFilter,
        priorityFilter: priorityFilter,
        assigneeFilter: assigneeFilter,
        errorMessage: errorMessage,
      ),
    );
  }

  @override
  void updateTaskInLoaded(int taskId, TaskDto updated) {
    final current = state;
    if (current is KanbanLoaded) {
      emitLoaded(
        current.allTasks.map((t) => t.id == taskId ? updated : t).toList(),
      );
    }
  }

  @override
  void setLoadedError(String msg) {
    final current = state;
    if (current is KanbanLoaded) emit(current.copyWith(errorMessage: msg));
  }

  void clearErrorMessage() {
    final current = state;
    if (current is KanbanLoaded && current.errorMessage != null) {
      emit(current.copyWith(errorMessage: null));
    }
  }

  @override
  void onFiltersUpdated() {
    final current = state;
    if (current is KanbanLoaded) emitLoaded(current.allTasks);
  }

  Future<void> loadTasks(int projectId, {bool forceRefresh = false}) async {
    _projectId = projectId;
    emit(const KanbanState.loading());

    await safeExecute(
      () async {
        try {
          final p = await _projectRepository.getProject(
            projectId,
            forceRefresh: forceRefresh,
          );
          _isArchived = p.statusEnum == ProjectStatus.archived;
          _workspaceId = p.workspaceId;
          await _signalRService?.joinWorkspace(p.workspaceId);
          subscribeToRealtime();
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
          emitLoaded(tasks);
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
      final tasks = await _taskRepository.getTasksByProject(
        _projectId!,
        forceRefresh: true,
      );
      if (tasks.isEmpty) {
        emit(
          KanbanState.empty(projectId: _projectId!, isArchived: _isArchived),
        );
      } else {
        final current = state;
        emitLoaded(
          tasks,
          errorMessage: current is KanbanLoaded ? current.errorMessage : null,
        );
      }
    } catch (_) {}
  }

  @override
  Future<void> close() {
    unsubscribeFromRealtime();
    if (_workspaceId != null) {
      _signalRService?.leaveWorkspace(_workspaceId!);
    }
    return super.close();
  }
}
