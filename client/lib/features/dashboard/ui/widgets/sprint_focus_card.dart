import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';

class SprintFocusCard extends StatelessWidget {
  final VoidCallback? onNavigateToMyTasks;

  const SprintFocusCard({super.key, this.onNavigateToMyTasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'My Active Focus',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (onNavigateToMyTasks != null)
                TextButton(
                  onPressed: onNavigateToMyTasks,
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const _FocusTaskTile(
            title: 'Implement Refresh Token Queue Interceptor',
            project: 'Mobile Client v1',
            priority: 'Urgent',
            priorityColor: AppColors.priorityUrgent,
            dueDate: 'Today',
          ),
          const SizedBox(height: 10),
          const _FocusTaskTile(
            title: 'Design 5-Column Responsive Kanban Matrix',
            project: 'Design Systems',
            priority: 'High',
            priorityColor: AppColors.priorityHigh,
            dueDate: 'Tomorrow',
          ),
          const SizedBox(height: 10),
          const _FocusTaskTile(
            title: 'Audit Postgres Migration Rollbacks',
            project: 'Backend API 10',
            priority: 'Medium',
            priorityColor: AppColors.priorityMedium,
            dueDate: 'Sep 05',
          ),
        ],
      ),
    );
  }
}

class _FocusTaskTile extends StatelessWidget {
  final String title;
  final String project;
  final String priority;
  final Color priorityColor;
  final String dueDate;

  const _FocusTaskTile({
    required this.title,
    required this.project,
    required this.priority,
    required this.priorityColor,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: priorityColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  project,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: priorityColor,
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
