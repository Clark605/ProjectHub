import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final priorityColor = task.priorityEnum.toColor();
    final isOverdue = task.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainer : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.border : AppColors.lightBorder,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Priority Indicator
                Container(
                  width: 4,
                  height: 36,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),

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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (task.projectName != null &&
                              task.projectName!.isNotEmpty) ...[
                            Text(
                              task.projectName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.lightTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                const SizedBox(width: 4),
                                Text(
                                  DateFormat('MMM d').format(task.dueDate!),
                                  style: TextStyle(
                                    fontSize: 12,
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
                const SizedBox(width: 8),

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
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: task.statusEnum.toColor().withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.statusEnum.toDisplayString(),
                        style: TextStyle(
                          fontSize: 11,
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
