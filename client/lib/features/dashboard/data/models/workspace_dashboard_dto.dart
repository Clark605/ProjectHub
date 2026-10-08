import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

class WorkspaceDashboardDto {
  final int activeProjectsCount;
  final int inProgressTasksCount;
  final int urgentTasksCount;
  final int completedTasksCount;
  final int overdueTasksCount;
  final int dueThisWeekTasksCount;
  final List<TaskDto> focusTasks;
  final List<ActivityEventDto> recentActivities;

  const WorkspaceDashboardDto({
    required this.activeProjectsCount,
    required this.inProgressTasksCount,
    required this.urgentTasksCount,
    required this.completedTasksCount,
    required this.overdueTasksCount,
    required this.dueThisWeekTasksCount,
    this.focusTasks = const [],
    this.recentActivities = const [],
  });

  factory WorkspaceDashboardDto.fromJson(Map<String, dynamic> json) {
    const requiredKeys = [
      'activeProjectsCount',
      'inProgressTasksCount',
      'urgentTasksCount',
      'completedTasksCount',
      'overdueTasksCount',
      'dueThisWeekTasksCount',
    ];

    for (final key in requiredKeys) {
      if (!json.containsKey(key) || json[key] == null) {
        throw FormatException('Missing required dashboard metric key: $key');
      }
    }

    return WorkspaceDashboardDto(
      activeProjectsCount: (json['activeProjectsCount'] as num).toInt(),
      inProgressTasksCount: (json['inProgressTasksCount'] as num).toInt(),
      urgentTasksCount: (json['urgentTasksCount'] as num).toInt(),
      completedTasksCount: (json['completedTasksCount'] as num).toInt(),
      overdueTasksCount: (json['overdueTasksCount'] as num).toInt(),
      dueThisWeekTasksCount: (json['dueThisWeekTasksCount'] as num).toInt(),
      focusTasks: (json['focusTasks'] as List<dynamic>?)
              ?.map((t) => TaskDto.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
      recentActivities: (json['recentActivities'] as List<dynamic>?)
              ?.map((a) => ActivityEventDto.fromJson(a as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'activeProjectsCount': activeProjectsCount,
    'inProgressTasksCount': inProgressTasksCount,
    'urgentTasksCount': urgentTasksCount,
    'completedTasksCount': completedTasksCount,
    'overdueTasksCount': overdueTasksCount,
    'dueThisWeekTasksCount': dueThisWeekTasksCount,
    'focusTasks': focusTasks.map((t) => t.toJson()).toList(),
    'recentActivities': recentActivities.map((a) => a.toJson()).toList(),
  };
}
