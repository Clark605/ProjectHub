import 'package:flutter/material.dart';

import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/widgets/app_badge.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/extensions/task_priority_ui.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';

class TaskDetailHeader extends StatelessWidget {
  final TaskDto task;
  final bool isArchived;
  final bool isEditMode;
  final VoidCallback onOpenStatusMove;
  final VoidCallback onStartEdit;
  final VoidCallback onCancelEdit;
  final VoidCallback onDelete;

  const TaskDetailHeader({
    super.key,
    required this.task,
    required this.isArchived,
    required this.isEditMode,
    required this.onOpenStatusMove,
    required this.onStartEdit,
    required this.onCancelEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      children: [
        InkWell(
          onTap: isArchived ? null : onOpenStatusMove,
          borderRadius: AppRadius.md,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: task.statusEnum.toColor().withValues(alpha: 0.15),
              borderRadius: AppRadius.md,
              border: Border.all(
                color: task.statusEnum.toColor().withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  task.statusEnum.toIcon(),
                  size: AppIconSize.xs,
                  color: task.statusEnum.toColor(),
                ),
                AppSpacing.gapWXs,
                Text(
                  task.statusEnum.localizedName(l10n),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: task.statusEnum.toColor(),
                  ),
                ),
                if (!isArchived) ...[
                  AppSpacing.gapWXs,
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: AppIconSize.sm,
                    color: task.statusEnum.toColor(),
                  ),
                ],
              ],
            ),
          ),
        ),
        AppSpacing.gapWSm,
        AppBadge(
          icon: task.priorityEnum.toIcon(),
          label: task.priorityEnum.localizedName(l10n),
          color: task.priorityEnum.toColor(),
        ),
        const Spacer(),
        if (!isEditMode) ...[
          if (!isArchived)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: AppIconSize.lg),
              tooltip: l10n.editTask,
              onPressed: onStartEdit,
            ),
          if (!isArchived)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: AppIconSize.lg,
                color: AppColors.error,
              ),
              tooltip: l10n.deleteTaskConfirmTitle,
              onPressed: onDelete,
            ),
        ] else ...[
          TextButton(onPressed: onCancelEdit, child: Text(l10n.cancel)),
        ],
      ],
    );
  }
}
