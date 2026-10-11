import 'package:client/core/errors/app_failure.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

class DashboardState {
  final bool isLoading;
  final int activeProjects;
  final int inProgressTasks;
  final int urgentTasks;
  final int completedTasks;
  final List<TaskDto> focusTasks;
  final List<ActivityEventDto> recentActivities;
  final AppFailure? failure;

  const DashboardState({
    this.isLoading = false,
    this.activeProjects = 0,
    this.inProgressTasks = 0,
    this.urgentTasks = 0,
    this.completedTasks = 0,
    this.focusTasks = const [],
    this.recentActivities = const [],
    this.failure,
  });

  /// Alias for backwards compatibility
  int get urgentBlockers => urgentTasks;

  DashboardState copyWith({
    bool? isLoading,
    int? activeProjects,
    int? inProgressTasks,
    int? urgentTasks,
    int? completedTasks,
    List<TaskDto>? focusTasks,
    List<ActivityEventDto>? recentActivities,
    AppFailure? failure,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      activeProjects: activeProjects ?? this.activeProjects,
      inProgressTasks: inProgressTasks ?? this.inProgressTasks,
      urgentTasks: urgentTasks ?? this.urgentTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      focusTasks: focusTasks ?? this.focusTasks,
      recentActivities: recentActivities ?? this.recentActivities,
      failure: failure,
    );
  }
}
