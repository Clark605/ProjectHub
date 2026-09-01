import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';

class WorkspacesScreen extends StatelessWidget {
  const WorkspacesScreen({super.key});

  void _onLogout(BuildContext context) async {
    final cubit = getIt<AppAuthCubit>();
    await cubit.logout();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: getIt<AppAuthCubit>(),
      child: BlocConsumer<AppAuthCubit, AppAuthState>(
        listener: (context, state) {
          state.whenOrNull(
            unauthenticated: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.login,
                (route) => false,
              );
            },
          );
        },
        builder: (context, state) {
          final user = state.whenOrNull(authenticated: (u) => u);

          return AmbientGlowBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text('Workspaces'),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.priorityHigh,
                    ),
                    tooltip: 'Logout',
                    onPressed: () => _onLogout(context),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.15),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              (user?.name.isNotEmpty == true)
                                  ? user!.name[0].toUpperCase()
                                  : 'U',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          user?.name ?? 'Welcome User',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (user?.email != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            user!.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 36),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 240),
                          child: AppButton(
                            label: 'Log Out',
                            icon: Icons.logout_rounded,
                            variant: AppButtonVariant.outline,
                            onPressed: () => _onLogout(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
