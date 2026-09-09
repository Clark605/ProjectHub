import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/core/widgets/app_avatar.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class DesktopSidebarUserProfile extends StatelessWidget {
  const DesktopSidebarUserProfile({super.key});

  void _onLogout(BuildContext context) async {
    final cubit = context.read<AppAuthCubit>();
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
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: theme.colorScheme.outlineVariant, height: 1),
        BlocProvider.value(
          value: getIt<AppAuthCubit>(),
          child: BlocBuilder<AppAuthCubit, AppAuthState>(
            builder: (context, state) {
              final user = state.whenOrNull(authenticated: (u) => u);

              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    AppAvatar(
                      name: user?.name ?? 'U',
                      size: 32,
                      backgroundColor: theme.colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      textStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'ProjectHub User',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.email ?? '',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: AppColors.priorityHigh,
                      ),
                      tooltip: l10n?.logOut ?? 'Logout',
                      onPressed: () => _onLogout(context),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
