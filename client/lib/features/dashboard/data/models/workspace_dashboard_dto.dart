class WorkspaceDashboardDto {
  final int totalProjects;
  final int activeProjects;
  final int inProgressTasks;
  final int urgentTasks;
  final int completedTasks;
  final int overdueTasks;
  final int dueThisWeekTasks;

  const WorkspaceDashboardDto({
    this.totalProjects = 0,
    this.activeProjects = 0,
    this.inProgressTasks = 0,
    this.urgentTasks = 0,
    this.completedTasks = 0,
    this.overdueTasks = 0,
    this.dueThisWeekTasks = 0,
  });

  factory WorkspaceDashboardDto.fromJson(Map<String, dynamic> json) {
    return WorkspaceDashboardDto(
      totalProjects: (json['totalProjects'] as num?)?.toInt() ?? 0,
      activeProjects: (json['activeProjects'] as num?)?.toInt() ?? 0,
      inProgressTasks: (json['inProgressTasks'] as num?)?.toInt() ?? 0,
      urgentTasks: (json['urgentTasks'] as num?)?.toInt() ?? 0,
      completedTasks: (json['completedTasks'] as num?)?.toInt() ?? 0,
      overdueTasks: (json['overdueTasks'] as num?)?.toInt() ?? 0,
      dueThisWeekTasks: (json['dueThisWeekTasks'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalProjects': totalProjects,
    'activeProjects': activeProjects,
    'inProgressTasks': inProgressTasks,
    'urgentTasks': urgentTasks,
    'completedTasks': completedTasks,
    'overdueTasks': overdueTasks,
    'dueThisWeekTasks': dueThisWeekTasks,
  };
}

