import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant),
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
              isArchived
                  ? (l10n?.noTasksArchived ?? 'No Tasks')
                  : (l10n?.boardIsEmpty ?? 'Board is Empty'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isArchived
                  ? (l10n?.noTasksArchivedSubtitle ??
                        'This project is archived and has no tasks recorded.')
                  : (l10n?.boardIsEmptySubtitle ??
                        'Start organizing your workflow by creating the first task for this project.'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isArchived && onCreateTask != null) ...[
              const SizedBox(height: 22),
              AppButton(
                label: l10n?.createFirstTask ?? 'Create First Task',
                icon: Icons.add_rounded,
                variant: AppButtonVariant.primary,
                onPressed: onCreateTask,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
