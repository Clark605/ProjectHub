import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/utils/date_formatter.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/extensions/task_priority_ui.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class MyTaskListTile extends StatelessWidget {
  final TaskDto task;
  final VoidCallback? onTap;
  final VoidCallback? onStatusTap;

  const MyTaskListTile({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;
    final priorityColor = task.priorityEnum.toColor();
    final isOverdue = task.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainer : AppColors.lightSurface,
        borderRadius: AppRadius.r12,
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.r12,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s14,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                // Priority Indicator
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: AppRadius.r2,
                  ),
                ),
                AppSpacing.gapW12,

                // Main Info: Title, Project Name, Due Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.gapH4,
                      Row(
                        children: [
                          if (task.projectName != null &&
                              task.projectName!.isNotEmpty) ...[
                            Flexible(
                              child: Text(
                                task.projectName!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : AppColors.lightTextSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            AppSpacing.gapW8,
                            Text(
                              '•',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            AppSpacing.gapW8,
                          ],
                          if (task.dueDate != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 12,
                                  color: isOverdue
                                      ? AppColors.error
                                      : (isDark
                                            ? AppColors.textSecondary
                                            : AppColors.lightTextSecondary),
                                ),
                                AppSpacing.gapW4,
                                Text(
                                  DateFormatter.formatShortDate(
                                    task.dueDate!,
                                    context: context,
                                  ),
                                  style: TextStyle(
                                    fontWeight: isOverdue
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isOverdue
                                        ? AppColors.error
                                        : (isDark
                                              ? AppColors.textSecondary
                                              : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapW8,

                // Status Badge
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onStatusTap,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: task.statusEnum.toColor().withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: AppRadius.r8,
                      ),
                      child: Text(
                        task.statusEnum.localizedName(l10n),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: task.statusEnum.toColor(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
