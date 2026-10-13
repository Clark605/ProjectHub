import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:flutter/material.dart';

class CreateTaskHeader extends StatelessWidget {
  final TaskStatus selectedStatus;

  const CreateTaskHeader({super.key, required this.selectedStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.pureWhite.withValues(alpha: 0.24)
                  : AppColors.pureBlack.withValues(alpha: 0.26),
              borderRadius: AppRadius.xs,
            ),
          ),
        ),
        AppSpacing.gapHLg,
        Row(
          children: [
            Text(
              l10n.createTask,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: selectedStatus.toColor().withValues(alpha: 0.15),
                borderRadius: AppRadius.md,
              ),
              child: Text(
                selectedStatus.localizedName(l10n),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selectedStatus.toColor(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
