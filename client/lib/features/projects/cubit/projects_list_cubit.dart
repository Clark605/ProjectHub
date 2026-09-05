import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_state.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/project_repository.dart';

@injectable
class ProjectsListCubit extends SafeActionCubit<ProjectsListState> {
  final ProjectRepository _projectRepository;
  int? _currentWorkspaceId;
  String _currentFilter = 'All';

  ProjectsListCubit(this._projectRepository)
    : super(const ProjectsListState.initial());

  int? get currentWorkspaceId => _currentWorkspaceId;
  String get currentFilter => _currentFilter;

  Future<void> loadProjects(
    int workspaceId, {
    bool forceRefresh = false,
    String? filter,
  }) async {
    _currentWorkspaceId = workspaceId;
    if (filter != null) {
      _currentFilter = filter;
    }

    emit(const ProjectsListState.loading());

    await safeExecute(
      () async {
        final all = await _projectRepository.getProjects(
          workspaceId,
          forceRefresh: forceRefresh,
        );

        if (all.isEmpty) {
          emit(ProjectsListState.empty(selectedFilter: _currentFilter));
          return;
        }

        final filtered = _applyFilter(all, _currentFilter);
        emit(
          ProjectsListState.loaded(
            projects: filtered,
            allProjects: all,
            selectedFilter: _currentFilter,
          ),
        );
      },
      onError: (message) => emit(ProjectsListState.error(message)),
      defaultErrorMessage: 'Failed to load projects',
      logTag: 'ProjectsListCubit',
    );
  }

  void filterByStatus(String status) {
    _currentFilter = status;

    final currentState = state;
    if (currentState is ProjectsListLoaded) {
      final filtered = _applyFilter(currentState.allProjects, status);
      emit(currentState.copyWith(projects: filtered, selectedFilter: status));
    } else {
      currentState.maybeWhen(
        empty: (_) => emit(ProjectsListState.empty(selectedFilter: status)),
        orElse: () {},
      );
    }
  }

  Future<ProjectDto?> createProject(CreateProjectRequest request) async {
    if (_currentWorkspaceId == null) return null;

    return await safeExecute<ProjectDto>(
      () async {
        final created = await _projectRepository.createProject(
          _currentWorkspaceId!,
          request,
        );

        final currentState = state;
        List<ProjectDto> updatedAll;
        if (currentState is ProjectsListLoaded) {
          updatedAll = [created, ...currentState.allProjects];
        } else {
          updatedAll = [created];
        }

        final filtered = _applyFilter(updatedAll, _currentFilter);
        emit(
          ProjectsListState.loaded(
            projects: filtered,
            allProjects: updatedAll,
            selectedFilter: _currentFilter,
          ),
        );

        return created;
      },
      onError: (message) => emit(ProjectsListState.error(message)),
      defaultErrorMessage: 'Failed to create project',
      logTag: 'ProjectsListCubit',
    );
  }

  void onProjectUpdated(ProjectDto updated) {
    final currentState = state;
    if (currentState is ProjectsListLoaded) {
      final updatedAll = currentState.allProjects
          .map((p) => p.id == updated.id ? updated : p)
          .toList();
      final filtered = _applyFilter(updatedAll, currentState.selectedFilter);
      emit(currentState.copyWith(projects: filtered, allProjects: updatedAll));
    }
  }

  void onProjectDeleted(int projectId) {
    final currentState = state;
    if (currentState is ProjectsListLoaded) {
      final updatedAll = currentState.allProjects
          .where((p) => p.id != projectId)
          .toList();

      if (updatedAll.isEmpty) {
        emit(
          ProjectsListState.empty(selectedFilter: currentState.selectedFilter),
        );
      } else {
        final filtered = _applyFilter(updatedAll, currentState.selectedFilter);
        emit(
          currentState.copyWith(projects: filtered, allProjects: updatedAll),
        );
      }
    }
  }

  List<ProjectDto> _applyFilter(List<ProjectDto> projects, String filter) {
    if (filter.isEmpty || filter.toLowerCase() == 'all') {
      return projects;
    }
    return projects
        .where((p) => p.status.toLowerCase() == filter.toLowerCase())
        .toList();
  }
}
