import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';

class KanbanEmptyState extends StatelessWidget {
  final bool isArchived;
  final VoidCallback? onCreateTask;

  const KanbanEmptyState({
    super.key,
    this.isArchived = false,
    this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.surfaceContainer : Colors.white)
              .withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.electricViolet.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.electricViolet.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.view_kanban_outlined,
                size: 30,
                color: AppColors.electricViolet,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isArchived ? 'No Tasks' : 'Board is Empty',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArchived
                  ? 'This project is archived and has no tasks recorded.'
                  : 'Start organizing your workflow by creating the first task for this project.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isArchived && onCreateTask != null) ...[
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: onCreateTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricViolet,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  'Create First Task',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
