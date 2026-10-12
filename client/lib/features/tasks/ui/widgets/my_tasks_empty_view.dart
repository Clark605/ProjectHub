import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class MyTasksEmptyView extends StatelessWidget {
  const MyTasksEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: AppSpacing.edgeInsetsAllXxl,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxxl,
        ),
        decoration: BoxDecoration(
          color:
              (isDark
                      ? theme.colorScheme.surfaceContainerLow
                      : theme.colorScheme.surface)
                  .withValues(alpha: 0.8),
          borderRadius: AppRadius.r20,
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
            AppSpacing.gapHXl,
            Text(
              l10n.noAssignedTasks,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            AppSpacing.gapHSm,
            Text(
              l10n.noAssignedTasksSubtitle,
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
