import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:flutter/material.dart';

class KanbanColumnHeader extends StatelessWidget {
  final TaskStatus status;
  final int taskCount;
  final bool isArchived;
  final Color? accent;
  final VoidCallback? onAddTask;

  const KanbanColumnHeader({
    super.key,
    required this.status,
    required this.taskCount,
    required this.isArchived,
    this.accent,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final statusColor = status.toColor();
    final statusName = status.localizedName(l10n);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.gapWSm,
                Flexible(
                  child: Text(
                    statusName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                        ? accent!.withValues(alpha: 0.12)
                        : (isDark
                              ? AppColors.pureWhite.withValues(alpha: 0.12)
                              : AppColors.pureBlack.withValues(alpha: 0.12)),
                    borderRadius: AppRadius.md,
                  ),
                  child: Text(
                    '$taskCount',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: accent ?? context.appColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isArchived && onAddTask != null)
            IconButton(
              icon: const Icon(Icons.add_rounded, size: AppIconSize.lg),
              tooltip: l10n.addTaskToStatus(statusName),
              constraints: const BoxConstraints(),
              padding: AppSpacing.edgeInsetsAllXs,
              onPressed: onAddTask,
            ),
        ],
      ),
    );
  }
}
