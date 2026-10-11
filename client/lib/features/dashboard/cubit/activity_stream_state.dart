import 'package:client/core/errors/app_failure.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/data/models/activity_filter.dart';

class ActivityStreamState {
  final bool isLoading;
  final bool isRefreshing;
  final List<ActivityEventDto> activities;
  final List<ActivityEventDto> filteredActivities;
  final ActivityFilter filter;
  final AppFailure? failure;

  const ActivityStreamState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.activities = const [],
    this.filteredActivities = const [],
    this.filter = const ActivityFilter.empty(),
    this.failure,
  });

  bool get isEmpty => !isLoading && filteredActivities.isEmpty;

  ActivityStreamState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<ActivityEventDto>? activities,
    List<ActivityEventDto>? filteredActivities,
    ActivityFilter? filter,
    AppFailure? failure,
    bool clearError = false,
  }) {
    return ActivityStreamState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      activities: activities ?? this.activities,
      filteredActivities: filteredActivities ?? this.filteredActivities,
      filter: filter ?? this.filter,
      failure: clearError ? null : (failure ?? this.failure),
    );
  }
}
