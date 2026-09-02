import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';

class UserTaskItem {
  final String title;
  final String project;
  final String status;
  final Color statusColor;
  final String priority;
  final Color priorityColor;
  final String dueDate;

  const UserTaskItem({
    required this.title,
    required this.project,
    required this.status,
    required this.statusColor,
    required this.priority,
    required this.priorityColor,
    required this.dueDate,
  });
}

class TaskCardWidget extends StatelessWidget {
  final UserTaskItem task;
  final VoidCallback? onStatusToggle;

  const TaskCardWidget({
    super.key,
    required this.task,
    this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Checkbox / Status Action
          InkWell(
            onTap: onStatusToggle,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: task.priorityColor,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 14,
                color: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Project
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.project,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      task.dueDate,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Priority Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: task.priorityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              task.priority,
              style: TextStyle(
                color: task.priorityColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
