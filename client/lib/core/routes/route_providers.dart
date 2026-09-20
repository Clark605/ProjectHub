import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/features/auth/cubit/forgot_password_cubit.dart';
import 'package:client/features/auth/cubit/login_cubit.dart';
import 'package:client/features/auth/cubit/register_cubit.dart';
import 'package:client/features/auth/cubit/reset_password_cubit.dart';
import 'package:client/features/auth/ui/screens/forgot_password_screen.dart';
import 'package:client/features/auth/ui/screens/login_screen.dart';
import 'package:client/features/auth/ui/screens/register_screen.dart';
import 'package:client/features/auth/ui/screens/reset_password_screen.dart';
import 'package:client/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:client/features/dashboard/ui/dashboard_screen.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/ui/kanban_screen.dart';
import 'package:client/features/onboarding/ui/onboarding_screen.dart';
import 'package:client/features/profile/cubit/profile_edit_cubit.dart';
import 'package:client/features/profile/ui/profile_screen.dart';
import 'package:client/features/projects/cubit/project_detail_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/ui/project_detail_screen.dart';
import 'package:client/features/projects/ui/projects_screen.dart';
import 'package:client/features/shell/ui/main_shell_screen.dart';
import 'package:client/features/tasks/cubit/my_tasks_cubit.dart';
import 'package:client/features/tasks/ui/my_tasks_screen.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/ui/workspace_settings_screen.dart';

/// Builds tab content for the main navigation shell.
/// Each tab receives its own scoped Cubit via an isolated [BlocProvider].
Widget buildShellTabContent(int index, {ValueChanged<int>? onSelectTab}) =>
    switch (index) {
      0 => BlocProvider(
        create: (_) => getIt<DashboardCubit>(),
        child: DashboardScreen(
          onNavigateToProjects: () => onSelectTab?.call(1),
          onNavigateToMyTasks: () => onSelectTab?.call(2),
        ),
      ),
      1 => const ProjectsScreen(),
      2 => BlocProvider(
        create: (_) => getIt<MyTasksCubit>(),
        child: const MyTasksScreen(),
      ),
      3 => BlocProvider(
        create: (_) => getIt<ProfileEditCubit>(),
        child: const ProfileScreen(),
      ),
      _ => const SizedBox.shrink(),
    };

/// Route builders with route-level [BlocProvider] encapsulation.

Widget buildOnboardingRoute() => const OnboardingScreen();

Widget buildLoginRoute() => BlocProvider(
  create: (_) => getIt<LoginCubit>(),
  child: const LoginScreen(),
);

Widget buildRegisterRoute() => BlocProvider(
  create: (_) => getIt<RegisterCubit>(),
  child: const RegisterScreen(),
);

Widget buildForgotPasswordRoute() => BlocProvider(
  create: (_) => getIt<ForgotPasswordCubit>(),
  child: const ForgotPasswordScreen(),
);

Widget buildResetPasswordRoute(String? email) => BlocProvider(
  create: (_) => getIt<ResetPasswordCubit>(),
  child: ResetPasswordScreen(initialEmail: email),
);

Widget buildShellRoute({int initialIndex = 0}) => BlocProvider(
  create: (_) => getIt<ProjectsListCubit>(),
  child: MainShellScreen(initialIndex: initialIndex),
);

Widget buildProjectDetailRoute(int projectId) => BlocProvider(
  create: (_) => getIt<ProjectDetailCubit>()..loadProject(projectId),
  child: ProjectDetailScreen(projectId: projectId),
);

Widget buildWorkspaceSettingsRoute() => BlocProvider(
  create: (_) => getIt<WorkspaceSettingsCubit>(),
  child: const WorkspaceSettingsScreen(),
);

Widget buildKanbanRoute({required int projectId, ProjectDto? initialProject}) =>
    BlocProvider(
      create: (_) => getIt<KanbanCubit>(),
      child: KanbanScreen(projectId: projectId, initialProject: initialProject),
    );
