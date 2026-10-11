import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_presence_avatars.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class ProjectsHeader extends StatelessWidget {
  const ProjectsHeader({super.key, required this.onCreatePressed});

  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    int? activeWsId;
    try {
      final wsState = context.read<WorkspaceContextCubit>().state;
      activeWsId = wsState.maybeMap(
        loaded: (l) => l.activeWorkspace.id,
        orElse: () => null,
      );
    } on Object catch (_) {
      // Allows rendering header in isolated widget tests without WorkspaceContextCubit
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.projectsTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    AppSpacing.gapH4,
                    Text(
                      l10n.projectsSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (activeWsId != null) ...[
                AppSpacing.gapW12,
                WorkspacePresenceAvatars(workspaceId: activeWsId),
              ],
              if (isDesktop) ...[
                AppSpacing.gapW16,
                AppButton(
                  label: l10n.createProject,
                  icon: Icons.add_rounded,
                  isExpanded: false,
                  onPressed: onCreatePressed,
                ),
              ],
            ],
          ),
          AppSpacing.gapH20,
        ],
      ),
    );
  }
}
