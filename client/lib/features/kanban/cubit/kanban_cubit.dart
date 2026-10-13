import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/errors/app_failure.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/kanban/cubit/kanban_filter_mixin.dart';
import 'package:client/features/kanban/cubit/kanban_realtime_mixin.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/kanban/cubit/kanban_task_actions_mixin.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/project_status.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/task_filter.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class KanbanCubit extends SafeActionCubit<KanbanState>
    with KanbanFilterMixin, KanbanRealtimeMixin, KanbanTaskActionsMixin {
  final TaskRepository _taskRepository;
  final ProjectRepository _projectRepository;
  final SignalRService? _signalRService;
  final WorkspaceRepository? _workspaceRepository;

  int? _projectId;
  int? _workspaceId;
  bool _isArchived = false;
  ProjectDto? _project;
  List<MemberDto> _members = [];

  @factoryMethod
  KanbanCubit(
    this._taskRepository,
    this._projectRepository, [
    this._signalRService,
    this._workspaceRepository,
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
  ProjectDto? get project => _project;
  List<MemberDto> get members => _members;

  void setProject(ProjectDto project) {
    _project = project;
    _isArchived = project.statusEnum == ProjectStatus.archived;
    final current = state;
    if (current is KanbanLoaded) {
      emit(current.copyWith(isArchived: _isArchived));
    } else if (current is KanbanEmpty) {
      emit(current.copyWith(isArchived: _isArchived));
    }
  }

  @override
  void emitLoaded(
    List<TaskDto> allTasks, {
    TaskFilter? filter,
    AppFailure? failure,
  }) {
    final activeFilter = filter ?? currentFilter;
    emit(
      KanbanState.loaded(
        projectId: _projectId ?? 0,
        tasks: applyFilters(allTasks, activeFilter),
        allTasks: allTasks,
        isArchived: _isArchived,
        filter: activeFilter,
        failure: failure,
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
  void setLoadedFailure(AppFailure failure) {
    final current = state;
    if (current is KanbanLoaded) {
      emit(current.copyWith(failure: failure));
    } else if (current is KanbanEmpty) {
      emit(current.copyWith(failure: failure));
    }
  }

  void clearFailure() {
    final current = state;
    if (current is KanbanLoaded && current.failure != null) {
      emit(current.copyWith(failure: null));
    } else if (current is KanbanEmpty && current.failure != null) {
      emit(current.copyWith(failure: null));
    }
  }

  Future<void> loadTasks(int projectId, {bool forceRefresh = false}) async {
    _projectId = projectId;
    emit(const KanbanState.loading());

    await safeExecute(
      () async {
        final p = await _projectRepository.getProject(
          projectId,
          forceRefresh: forceRefresh,
        );
        _project = p;
        _isArchived = p.statusEnum == ProjectStatus.archived;
        _workspaceId = p.workspaceId;

        try {
          await _signalRService?.joinWorkspace(p.workspaceId);
          subscribeToRealtime();
        } on Object catch (e, st) {
          AppLogger.warning(
            'Failed to join realtime workspace ${p.workspaceId}: $e',
            tag: 'KanbanCubit',
            error: e,
            stackTrace: st,
          );
        }

        if (_workspaceRepository != null) {
          try {
            _members = await _workspaceRepository.getMembers(p.workspaceId);
          } on Object catch (e, st) {
            AppLogger.warning(
              'Failed to load workspace members for ${p.workspaceId}: $e',
              tag: 'KanbanCubit',
              error: e,
              stackTrace: st,
            );
          }
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
      onFailure: (failure) => emit(KanbanState.error(failure)),
      logTag: 'KanbanCubit',
    );
  }

  Future<void> refreshTasks({bool forceRefresh = true}) async {
    if (_projectId == null) return;
    final current = state;
    if (current is! KanbanLoaded && current is! KanbanEmpty) {
      await loadTasks(_projectId!, forceRefresh: forceRefresh);
      return;
    }

    await safeExecute(
      () async {
        final tasks = await _taskRepository.getTasksByProject(
          _projectId!,
          forceRefresh: forceRefresh,
        );
        if (tasks.isEmpty) {
          emit(
            KanbanState.empty(projectId: _projectId!, isArchived: _isArchived),
          );
        } else {
          emitLoaded(tasks);
        }
      },
      onFailure: setLoadedFailure,
      logTag: 'KanbanCubit',
    );
  }

  @override
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
          failure: current is KanbanLoaded ? current.failure : null,
        );
      }
    } on Object catch (_) {
      // Silent catch on background task refresh to avoid interrupting UI interaction
    }
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
