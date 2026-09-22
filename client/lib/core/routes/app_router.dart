import 'package:flutter/material.dart';

import 'package:client/core/routes/route_names.dart';
import 'package:client/core/routes/route_providers.dart';
import 'package:client/features/projects/data/models/project_dto.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.onboarding:
        return _fadeRoute(buildOnboardingRoute(), settings);
      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => buildLoginRoute(),
          settings: settings,
        );
      case RouteNames.register:
        return _fadeRoute(buildRegisterRoute(), settings);
      case RouteNames.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => buildForgotPasswordRoute(),
          settings: settings,
        );
      case RouteNames.resetPassword:
        final email = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => buildResetPasswordRoute(email),
          settings: settings,
        );
      case RouteNames.shell:
      case RouteNames.dashboard:
        return _fadeRoute(buildShellRoute(initialIndex: 0), settings);
      case RouteNames.projects:
        return _fadeRoute(buildShellRoute(initialIndex: 1), settings);
      case RouteNames.projectDetail:
        final args = settings.arguments;
        final projectId = args is int
            ? args
            : int.tryParse(args?.toString() ?? '') ?? 0;
        return MaterialPageRoute(
          builder: (_) => buildProjectDetailRoute(projectId),
          settings: settings,
        );
      case RouteNames.myTasks:
        return _fadeRoute(buildShellRoute(initialIndex: 2), settings);
      case RouteNames.profile:
        return _fadeRoute(buildShellRoute(initialIndex: 3), settings);
      case RouteNames.workspaces:
        return MaterialPageRoute(
          builder: (_) => buildWorkspaceSettingsRoute(),
          settings: settings,
        );
      case RouteNames.kanban:
        final args = settings.arguments;
        final int projectId;
        final ProjectDto? project;
        if (args is ProjectDto) {
          project = args;
          projectId = args.id;
        } else if (args is int) {
          projectId = args;
          project = null;
        } else if (args is Map<String, dynamic>) {
          projectId = args['projectId'] as int? ?? 0;
          project = args['project'] as ProjectDto?;
        } else {
          projectId = int.tryParse(args?.toString() ?? '') ?? 0;
          project = null;
        }
        return _fadeRoute(
          buildKanbanRoute(projectId: projectId, initialProject: project),
          settings,
        );
      case RouteNames.activityStream:
        final args = settings.arguments;
        final workspaceId = args is int
            ? args
            : int.tryParse(args?.toString() ?? '') ?? 0;
        return _fadeRoute(buildActivityStreamRoute(workspaceId), settings);
      default:
        return null;
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
