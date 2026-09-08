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
          ? 'https://vhtl5fd3-5259.uks1.devtunnels.ms/' // Real Android device (LAN IP)
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
  static String workspaceProjects(int id) => '$_v1/workspaces/$id/projects';
  static String workspaceMyTasks(int id) => '$_v1/workspaces/$id/my-tasks';
  static String workspaceActivity(int id, {int limit = 20}) =>
      '$_v1/workspaces/$id/activity?limit=$limit';

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
}
