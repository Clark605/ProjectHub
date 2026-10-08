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
  final String? errorMessage;

  const DashboardState({
    this.isLoading = false,
    this.activeProjects = 0,
    this.inProgressTasks = 0,
    this.urgentTasks = 0,
    this.completedTasks = 0,
    this.focusTasks = const [],
    this.recentActivities = const [],
    this.errorMessage,
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
    String? errorMessage,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      activeProjects: activeProjects ?? this.activeProjects,
      inProgressTasks: inProgressTasks ?? this.inProgressTasks,
      urgentTasks: urgentTasks ?? this.urgentTasks,
      completedTasks: completedTasks ?? this.completedTasks,
      focusTasks: focusTasks ?? this.focusTasks,
      recentActivities: recentActivities ?? this.recentActivities,
      errorMessage: errorMessage,
    );
  }
}
