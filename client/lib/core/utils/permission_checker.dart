enum WorkspaceRole { owner, member }

class TaskItem {
  final String createdBy;
  final String? assigneeId;

  const TaskItem({required this.createdBy, this.assigneeId});
}

class PermissionChecker {
  PermissionChecker._();

  /// Can manage workspace settings (edit, delete, invite/remove members)
  static bool canManageWorkspace(WorkspaceRole role) =>
      role == WorkspaceRole.owner;

  /// Can edit project metadata
  static bool canEditProject({
    required WorkspaceRole role,
    required String projectCreatorId,
    required String currentUserId,
  }) =>
      role == WorkspaceRole.owner ||
      (projectCreatorId.isNotEmpty &&
          currentUserId.isNotEmpty &&
          projectCreatorId == currentUserId);

  /// Can delete a project
  static bool canDeleteProject({
    required WorkspaceRole role,
    required String projectCreatorId,
    required String currentUserId,
  }) =>
      role == WorkspaceRole.owner ||
      (projectCreatorId.isNotEmpty &&
          currentUserId.isNotEmpty &&
          projectCreatorId == currentUserId);

  /// Can edit a task or move its status
  static bool canEditTask({
    required WorkspaceRole role,
    required TaskItem task,
    required String currentUserId,
  }) =>
      role == WorkspaceRole.owner ||
      (currentUserId.isNotEmpty &&
          ((task.createdBy.isNotEmpty && task.createdBy == currentUserId) ||
              (task.assigneeId != null &&
                  task.assigneeId!.isNotEmpty &&
                  task.assigneeId == currentUserId)));

  /// Can delete a task
  static bool canDeleteTask({
    required WorkspaceRole role,
    required TaskItem task,
    required String currentUserId,
  }) =>
      role == WorkspaceRole.owner ||
      (currentUserId.isNotEmpty &&
          task.createdBy.isNotEmpty &&
          task.createdBy == currentUserId);
}
