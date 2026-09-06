class PermissionChecker {
  PermissionChecker._();

  static bool _isOwner(String roleStr) {
    return roleStr.toLowerCase() == 'owner' || roleStr.toLowerCase() == 'workspacerole.owner';
  }

  /// Can manage workspace settings (edit, delete, invite/remove members)
  static bool canManageWorkspace(String role) =>
      _isOwner(role);

  /// Can edit project metadata
  static bool canEditProject({
    required String role,
    required String projectCreatorId,
    required String currentUserId,
  }) =>
      _isOwner(role) ||
      (projectCreatorId.isNotEmpty &&
          currentUserId.isNotEmpty &&
          projectCreatorId == currentUserId);

  /// Can delete a project
  static bool canDeleteProject({
    required String role,
    required String projectCreatorId,
    required String currentUserId,
  }) =>
      _isOwner(role) ||
      (projectCreatorId.isNotEmpty &&
          currentUserId.isNotEmpty &&
          projectCreatorId == currentUserId);

  /// Can edit a task or move its status
  static bool canEditTask({
    required String role,
    required String taskCreatedBy,
    String? taskAssigneeId,
    required String currentUserId,
  }) =>
      _isOwner(role) ||
      (currentUserId.isNotEmpty &&
          ((taskCreatedBy.isNotEmpty && taskCreatedBy == currentUserId) ||
              (taskAssigneeId != null &&
                  taskAssigneeId.isNotEmpty &&
                  taskAssigneeId == currentUserId)));

  /// Can delete a task
  static bool canDeleteTask({
    required String role,
    required String taskCreatedBy,
    required String currentUserId,
  }) =>
      _isOwner(role) ||
      (currentUserId.isNotEmpty &&
          taskCreatedBy.isNotEmpty &&
          taskCreatedBy == currentUserId);
}
