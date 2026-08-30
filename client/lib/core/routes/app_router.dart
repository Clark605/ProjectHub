import 'package:flutter/material.dart';

import 'package:client/core/routes/route_names.dart';
import 'package:client/features/auth/ui/screens/forgot_password_screen.dart';
import 'package:client/features/auth/ui/screens/login_screen.dart';
import 'package:client/features/auth/ui/screens/register_screen.dart';
import 'package:client/features/auth/ui/screens/reset_password_screen.dart';
import 'package:client/features/onboarding/ui/onboarding_screen.dart';
import 'package:client/features/workspaces/ui/workspaces_screen.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.onboarding:
        return _fadeRoute(const OnboardingScreen(), settings);
      case RouteNames.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case RouteNames.register:
        return _fadeRoute(const RegisterScreen(), settings);
      case RouteNames.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          settings: settings,
        );
      case RouteNames.resetPassword:
        final email = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(initialEmail: email),
          settings: settings,
        );
      case RouteNames.workspaces:
        return MaterialPageRoute(
          builder: (_) => const WorkspacesScreen(),
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
