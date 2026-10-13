import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/widgets/my_task_list_tile.dart';
import 'package:flutter/material.dart';

class MyTasksSection extends StatelessWidget {
  final String emoji;
  final String title;
  final List<TaskDto> tasks;
  final bool isCollapsible;
  final bool isCollapsed;
  final String? activeWorkspaceAccent;
  final VoidCallback? onToggleCollapse;
  final ValueChanged<TaskDto>? onTaskTap;
  final ValueChanged<TaskDto>? onTaskStatusTap;

  const MyTasksSection({
    super.key,
    required this.emoji,
    required this.title,
    required this.tasks,
    this.isCollapsible = false,
    this.isCollapsed = false,
    this.activeWorkspaceAccent,
    this.onToggleCollapse,
    this.onTaskTap,
    this.onTaskStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final accent =
        activeWorkspaceAccent != null &&
            activeWorkspaceAccent!.trim().isNotEmpty
        ? WorkspaceAccent.fromId(
            activeWorkspaceAccent,
          ).resolvedColor(theme.brightness)
        : null;

    if (tasks.isEmpty && !isCollapsible) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        InkWell(
          onTap: isCollapsible ? onToggleCollapse : null,
          borderRadius: AppRadius.sm,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm,
              horizontal: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Text(emoji, style: theme.textTheme.titleMedium),
                AppSpacing.gapWSm,
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                AppSpacing.gapWSm,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: accent != null
                        ? accent.withValues(alpha: 0.12)
                        : (isDark
                              ? AppColors.pureWhite.withValues(alpha: 0.12)
                              : AppColors.pureBlack.withValues(alpha: 0.12)),
                    borderRadius: AppRadius.md,
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          accent ??
                          (isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary),
                    ),
                  ),
                ),
                const Spacer(),
                if (isCollapsible)
                  Icon(
                    isCollapsed
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    size: AppIconSize.lg,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
              ],
            ),
          ),
        ),
        AppSpacing.gapHXs,

        // Section Body
        if (!isCollapsed) ...[
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm,
                horizontal: AppSpacing.sm,
              ),
              child: Text(
                l10n.noTasksInSection,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...tasks.map(
              (task) => MyTaskListTile(
                task: task,
                onTap: () => onTaskTap?.call(task),
                onStatusTap: () => onTaskStatusTap?.call(task),
              ),
            ),
        ],
        AppSpacing.gapHMd,
      ],
    );
  }
}
