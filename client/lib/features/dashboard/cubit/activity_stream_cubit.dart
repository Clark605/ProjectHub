import 'dart:async';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/theme/app_durations.dart';
import 'package:client/features/dashboard/cubit/activity_stream_state.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/data/models/activity_filter.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class ActivityStreamCubit extends SafeActionCubit<ActivityStreamState> {
  final ActivityRepository _repository;
  final ProjectRepository? _projectRepository;
  int? _workspaceId;
  Timer? _debounceTimer;
  int _requestId = 0;

  ActivityStreamCubit(
    this._repository, [
    this._projectRepository,
  ]) : super(const ActivityStreamState(isLoading: true));

  int? get workspaceId => _workspaceId;
  ActivityFilter get currentFilter => state.filter;

  Future<void> loadActivities(
    int workspaceId, {
    bool forceRefresh = false,
    ActivityFilter? filter,
  }) async {
    _workspaceId = workspaceId;
    _debounceTimer?.cancel();
    final requestId = ++_requestId;

    final targetFilter = filter ?? state.filter;

    if (forceRefresh) {
      emit(state.copyWith(isRefreshing: true, clearFailure: true));
    } else {
      emit(
        state.copyWith(
          isLoading: true,
          filter: targetFilter,
          clearFailure: true,
        ),
      );
    }

    await safeExecute(
      () async {
        final items = await _repository.getWorkspaceActivities(
          workspaceId,
          limit: 50,
          filter: targetFilter,
        );

        List<ProjectDto> projects = state.availableProjects;
        if (_projectRepository != null && state.availableProjects.isEmpty) {
          try {
            projects = await _projectRepository.getProjects(workspaceId);
          } on Object catch (_) {
            // Non-critical project list safely falls back to empty
          }
        }

        if (requestId != _requestId) return;

        final filtered = targetFilter.apply(items);
        emit(
          state.copyWith(
            isLoading: false,
            isRefreshing: false,
            activities: items,
            filteredActivities: filtered,
            availableProjects: projects,
            filter: targetFilter,
            clearFailure: true,
          ),
        );
      },
      onFailure: (failure) {
        if (requestId != _requestId) return;
        emit(
          state.copyWith(
            isLoading: false,
            isRefreshing: false,
            failure: failure,
          ),
        );
      },
      logTag: 'ActivityStreamCubit',
    );
  }

  void setAvailableProjects(List<ProjectDto> projects) {
    emit(state.copyWith(availableProjects: projects));
  }

  void updateFilter(ActivityFilter newFilter, {bool debounce = false}) {
    // 1. Immediately apply filter client-side over currently cached activities for instant UI responsiveness
    final localFiltered = newFilter.apply(state.activities);
    emit(state.copyWith(filter: newFilter, filteredActivities: localFiltered));

    if (_workspaceId == null) return;

    _debounceTimer?.cancel();
    if (debounce) {
      // 2. Debounce backend query by 300ms to avoid network thrashing during live input
      _debounceTimer = Timer(AppDurations.medium, () {
        _fetchFilteredActivities(newFilter);
      });
    } else {
      _fetchFilteredActivities(newFilter);
    }
  }

  void updateCategory(String category) {
    final updated = state.filter.copyWith(category: category);
    updateFilter(updated, debounce: false);
  }

  void clearFilters() {
    updateFilter(const ActivityFilter.empty(), debounce: false);
  }

  Future<void> _fetchFilteredActivities(ActivityFilter targetFilter) async {
    if (_workspaceId == null) return;

    final requestId = ++_requestId;

    await safeExecute(
      () async {
        final items = await _repository.getWorkspaceActivities(
          _workspaceId!,
          limit: 50,
          filter: targetFilter,
        );

        if (requestId != _requestId) return;

        final filtered = targetFilter.apply(items);
        emit(
          state.copyWith(
            activities: items,
            filteredActivities: filtered,
            clearFailure: true,
          ),
        );
      },
      onFailure: (failure) {
        if (requestId != _requestId) return;
        emit(state.copyWith(failure: failure));
      },
      logTag: 'ActivityStreamCubit',
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
