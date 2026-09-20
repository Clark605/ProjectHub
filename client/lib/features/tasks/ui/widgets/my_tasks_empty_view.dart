import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class MyTasksEmptyView extends StatelessWidget {
  const MyTasksEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color:
              (isDark
                      ? theme.colorScheme.surfaceContainerLow
                      : theme.colorScheme.surface)
                  .withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.skyBlue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.skyBlue.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: AppColors.skyBlue,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n?.noAssignedTasks ?? 'No Assigned Tasks',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.noAssignedTasksSubtitle ??
                  'You have no pending tasks assigned in this workspace. Take a break or check project boards!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
