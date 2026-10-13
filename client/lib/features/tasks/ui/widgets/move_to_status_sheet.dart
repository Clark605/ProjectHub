import 'package:client/core/dialog/app_bottom_sheet.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:flutter/material.dart';

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
    final l10n = context.l10n;
    final currentStatus = task.statusEnum;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSheetDragHandle(),
          AppSpacing.gapHMd,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.moveTask,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                AppSpacing.gapHXs,
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
          AppSpacing.gapHLg,
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          AppSpacing.gapHSm,
          ...TaskStatus.values.map((status) {
            final isCurrent = status == currentStatus;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: AppRadius.md,
                onTap: isCurrent ? null : () => onStatusSelected(status),
                child: Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: status.toColor().withValues(alpha: 0.15),
                          borderRadius: AppRadius.sm,
                        ),
                        child: Icon(
                          status.toIcon(),
                          size: AppIconSize.lg,
                          color: status.toColor(),
                        ),
                      ),
                      AppSpacing.gapWMd,
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
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: status.toColor().withValues(alpha: 0.15),
                            borderRadius: AppRadius.md,
                          ),
                          child: Text(
                            l10n.currentStatus,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: status.toColor(),
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: AppIconSize.xs,
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
