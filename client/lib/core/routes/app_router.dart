import 'package:flutter/material.dart';

import 'package:client/core/routes/route_names.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.onboarding:
        return _fadeRoute(
          const Scaffold(body: Center(child: Text('Onboarding'))),
          settings,
        );
      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Login'))),
          settings: settings,
        );
      case RouteNames.register:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Register'))),
          settings: settings,
        );
      case RouteNames.workspaces:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Workspaces'))),
          settings: settings,
        );
      case RouteNames.projects:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Projects'))),
          settings: settings,
        );
      case RouteNames.kanban:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Kanban'))),
          settings: settings,
        );
      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Profile'))),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('404 — Page Not Found'))),
          settings: settings,
        );
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
