import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/dashboard/cubit/activity_stream_state.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/data/models/activity_filter.dart';

@injectable
class ActivityStreamCubit extends SafeActionCubit<ActivityStreamState> {
  final ActivityRepository _repository;
  int? _workspaceId;
  Timer? _debounceTimer;
  int _requestId = 0;

  ActivityStreamCubit(this._repository)
      : super(const ActivityStreamState(isLoading: true));

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
      emit(state.copyWith(isRefreshing: true, clearError: true));
    } else {
      emit(
        state.copyWith(
          isLoading: true,
          filter: targetFilter,
          clearError: true,
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

        if (requestId != _requestId) return;

        final filtered = targetFilter.apply(items);
        emit(
          state.copyWith(
            isLoading: false,
            isRefreshing: false,
            activities: items,
            filteredActivities: filtered,
            filter: targetFilter,
            clearError: true,
          ),
        );
      },
      onError: (message) {
        if (requestId != _requestId) return;
        emit(
          state.copyWith(
            isLoading: false,
            isRefreshing: false,
            errorMessage: message,
          ),
        );
      },
      defaultErrorMessage: 'Failed to load activity stream',
      logTag: 'ActivityStreamCubit',
    );
  }

  void updateFilter(ActivityFilter newFilter, {bool debounce = false}) {
    // 1. Immediately apply filter client-side over currently cached activities for instant UI responsiveness
    final localFiltered = newFilter.apply(state.activities);
    emit(state.copyWith(filter: newFilter, filteredActivities: localFiltered));

    if (_workspaceId == null) return;

    _debounceTimer?.cancel();
    if (debounce) {
      // 2. Debounce backend query by 300ms to avoid network thrashing during live input
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
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
            clearError: true,
          ),
        );
      },
      onError: (message) {
        if (requestId != _requestId) return;
        emit(state.copyWith(errorMessage: message));
      },
      defaultErrorMessage: 'Failed to filter activity stream',
      logTag: 'ActivityStreamCubit',
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
