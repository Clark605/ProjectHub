import 'package:flutter/material.dart';

import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/widgets/app_badge.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/extensions/task_priority_ui.dart';

class FocusTaskTile extends StatelessWidget {
  final TaskDto task;

  const FocusTaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final priorityColor = task.priorityEnum.toColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: AppRadius.md,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
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
          AppSpacing.gapWMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.gapHXxs,
                Text(
                  task.projectName ?? 'Task #${task.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapWMd,
          AppBadge(
            icon: task.priorityEnum.toIcon(),
            label: task.priorityEnum.localizedName(l10n),
            color: priorityColor,
          ),
        ],
      ),
    );
  }
}
