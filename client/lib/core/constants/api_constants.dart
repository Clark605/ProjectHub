class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:5259';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Users
  static const String userProfile = '/users/me';

  // Workspaces
  static const String workspaces = '/workspaces';
  static String workspaceById(int id) => '/workspaces/$id';
  static String workspaceMembers(int id) => '/workspaces/$id/members';
  static String removeWorkspaceMember(int workspaceId, String userId) =>
      '/workspaces/$workspaceId/members/$userId';
  static String workspaceProjects(int id) => '/workspaces/$id/projects';

  // Projects
  static String projectById(int id) => '/projects/$id';
  static String projectTasks(int id) => '/projects/$id/tasks';

  // Tasks
  static String taskById(int id) => '/tasks/$id';
  static String taskStatus(int id) => '/tasks/$id/status';
  static String taskAssignee(int id) => '/tasks/$id/assignee';
}
