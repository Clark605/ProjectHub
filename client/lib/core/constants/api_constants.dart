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

  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:5259';
    if (Platform.isAndroid) {
      return isPhysicalDevice
          ? 'http://192.168.1.8:5259' // Real Android device (LAN IP)
          : 'http://10.0.2.2:5259'; // Android emulator (host loopback)
    }
    return 'http://127.0.0.1:5259'; // iOS simulator / Desktop
  }

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
