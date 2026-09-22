import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  static bool isPhysicalDevice = false;

  /// Initializes device-specific configuration (e.g., emulator vs physical device detection).
  static Future<void> init() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        isPhysicalDevice = androidInfo.isPhysicalDevice;
      } catch (_) {
        // Fallback gracefully if device info cannot be retrieved
      }
    }
  }

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;

    if (kIsWeb) return 'http://127.0.0.1:5259';
    if (Platform.isAndroid) {
      return isPhysicalDevice
          ? 'http://10.0.2.2:5259' // Configure via --dart-define=API_BASE_URL=https://<your-tunnel>
          : 'http://10.0.2.2:5259'; // Android emulator (host loopback)
    }
    return 'http://127.0.0.1:5259'; // iOS simulator / Desktop
  }

  static const String _v1 = '/api/v1';

  // Auth
  static const String register = '$_v1/auth/register';
  static const String login = '$_v1/auth/login';
  static const String refresh = '$_v1/auth/refresh';
  static const String logout = '$_v1/auth/logout';
  static const String forgotPassword = '$_v1/auth/forgot-password';
  static const String resetPassword = '$_v1/auth/reset-password';
  static const String externalLogin = '$_v1/auth/external-login';

  // Users
  static const String userProfile = '$_v1/users/me';

  // Workspaces
  static const String workspaces = '$_v1/workspaces';
  static String workspaceById(int id) => '$_v1/workspaces/$id';
  static String workspaceMembers(int id) => '$_v1/workspaces/$id/members';
  static String removeWorkspaceMember(int workspaceId, String userId) =>
      '$_v1/workspaces/$workspaceId/members/$userId';
  static String updateMemberRole(int workspaceId, String memberId) =>
      '$_v1/workspaces/$workspaceId/members/$memberId/role';
  static String workspaceProjects(int id) => '$_v1/workspaces/$id/projects';
  static String workspaceMyTasks(int id) => '$_v1/workspaces/$id/my-tasks';
  static String workspaceActivity(
    int id, {
    int limit = 20,
    String? eventType,
    String? search,
    String? sortBy,
    bool? sortDescending,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final params = <String, String>{'limit': limit.toString()};
    if (eventType != null && eventType.isNotEmpty) {
      params['eventType'] = eventType;
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    if (sortBy != null && sortBy.isNotEmpty) {
      params['sortBy'] = sortBy;
    }
    if (sortDescending != null) {
      params['sortDescending'] = sortDescending.toString();
    }
    if (startDate != null) {
      params['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      params['endDate'] = endDate.toIso8601String();
    }

    final query = Uri(queryParameters: params).query;
    return '$_v1/workspaces/$id/activity?$query';
  }

  // Projects
  static String projectById(int id) => '$_v1/projects/$id';
  static String projectTasks(int id) => '$_v1/projects/$id/tasks';
  static String projectActivity(int id, {int limit = 50}) =>
      '$_v1/projects/$id/activity?limit=$limit';

  // Tasks
  static String taskById(int id) => '$_v1/tasks/$id';
  static String taskStatus(int id) => '$_v1/tasks/$id/status';
  static String taskAssignee(int id) => '$_v1/tasks/$id/assignee';

  // Health
  static const String health = '$_v1/health';

  // SignalR Hub
  static String get workspaceHubUrl => '$baseUrl$_v1/hubs/workspace';

  // Comments
  static String taskComments(int taskId) => '$_v1/tasks/$taskId/comments';
  static String commentById(int id) => '$_v1/comments/$id';

  // Tags
  static String workspaceTags(int workspaceId) =>
      '$_v1/workspaces/$workspaceId/tags';
  static String projectTags(int projectId) => '$_v1/projects/$projectId/tags';
  static String projectAvailableTags(int projectId) =>
      '$_v1/projects/$projectId/available-tags';
  static String taskTags(int taskId) => '$_v1/tasks/$taskId/tags';
  static String taskTag(int taskId, int tagId) =>
      '$_v1/tasks/$taskId/tags/$tagId';
  static String tagById(int id) => '$_v1/tags/$id';
}
