import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/extensions/task_priority_ui.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        InkWell(
          onTap: isArchived ? null : onOpenStatusMove,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: task.statusEnum.toColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: task.statusEnum.toColor().withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  task.statusEnum.toIcon(),
                  size: 14,
                  color: task.statusEnum.toColor(),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n != null
                      ? task.statusEnum.localizedName(l10n)
                      : task.statusEnum.toDisplayString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: task.statusEnum.toColor(),
                  ),
                ),
                if (!isArchived) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 16,
                    color: task.statusEnum.toColor(),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: task.priorityEnum.toColor().withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                task.priorityEnum.toIcon(),
                size: 14,
                color: task.priorityEnum.toColor(),
              ),
              const SizedBox(width: 4),
              Text(
                l10n != null
                    ? task.priorityEnum.localizedName(l10n)
                    : task.priorityEnum.toDisplayString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: task.priorityEnum.toColor(),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (!isEditMode) ...[
          if (!isArchived)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: l10n?.editTask ?? 'Edit Task',
              onPressed: onStartEdit,
            ),
          if (!isArchived)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: AppColors.error,
              ),
              tooltip: l10n?.deleteTaskConfirmTitle ?? 'Delete Task',
              onPressed: onDelete,
            ),
        ] else ...[
          TextButton(
            onPressed: onCancelEdit,
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
        ],
      ],
    );
  }
}
