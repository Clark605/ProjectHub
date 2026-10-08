import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/dialog/app_bottom_sheet.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class MoveToStatusSheet extends StatelessWidget {
  final TaskDto task;
  final ValueChanged<TaskStatus> onStatusSelected;

  const MoveToStatusSheet({
    super.key,
    required this.task,
    required this.onStatusSelected,
  });

  static Future<TaskStatus?> show(
    BuildContext context, {
    required TaskDto task,
    required ValueChanged<TaskStatus> onStatusSelected,
  }) {
    return showAppBottomSheet<TaskStatus>(
      context: context,
      builder: (sheetContext) => MoveToStatusSheet(
        task: task,
        onStatusSelected: (status) {
          Navigator.of(sheetContext).pop(status);
          onStatusSelected(status);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentStatus = task.statusEnum;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSheetDragHandle(),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.moveTask,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 8),
          ...TaskStatus.values.map((status) {
            final isCurrent = status == currentStatus;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppRadius.r12,
                onTap: isCurrent ? null : () => onStatusSelected(status),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: status.toColor().withValues(alpha: 0.15),
                          borderRadius: AppRadius.r8,
                        ),
                        child: Icon(
                          status.toIcon(),
                          size: 20,
                          color: status.toColor(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          status.localizedName(l10n),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isCurrent
                                ? status.toColor()
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: status.toColor().withValues(alpha: 0.15),
                            borderRadius: AppRadius.r10,
                          ),
                          child: Text(
                            l10n.currentStatus,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: status.toColor(),
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
