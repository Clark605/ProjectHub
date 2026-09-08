import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

class DashboardState {
  final bool isLoading;
  final int totalProjects;
  final int activeProjects;
  final int inProgressTasks;
  final int urgentBlockers;
  final int completedTasks;
  final List<TaskDto> focusTasks;
  final List<ActivityEventDto> recentActivities;
  final String? errorMessage;

  const DashboardState({
    this.isLoading = false,
    this.totalProjects = 0,
    this.activeProjects = 0,
    this.inProgressTasks = 0,
    this.urgentBlockers = 0,
    this.completedTasks = 0,
    this.focusTasks = const [],
    this.recentActivities = const [],
    this.errorMessage,
  });

  DashboardState copyWith({
    bool? isLoading,
    int? totalProjects,
    int? activeProjects,
    int? inProgressTasks,
    int? urgentBlockers,
    int? completedTasks,
    List<TaskDto>? focusTasks,
    List<ActivityEventDto>? recentActivities,
    String? errorMessage,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      totalProjects: totalProjects ?? this.totalProjects,
      activeProjects: activeProjects ?? this.activeProjects,
      inProgressTasks: inProgressTasks ?? this.inProgressTasks,
      urgentBlockers: urgentBlockers ?? this.urgentBlockers,
      completedTasks: completedTasks ?? this.completedTasks,
      focusTasks: focusTasks ?? this.focusTasks,
      recentActivities: recentActivities ?? this.recentActivities,
      errorMessage: errorMessage,
    );
  }
}
