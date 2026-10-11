import 'package:flutter/material.dart';

import 'package:client/core/theme/app_radius.dart';
import 'package:client/features/dashboard/ui/widgets/focus_task_tile.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class FocusTasksCard extends StatelessWidget {
  final List<TaskDto> focusTasks;
  final bool isLoading;
  final VoidCallback? onNavigateToMyTasks;

  const FocusTasksCard({
    super.key,
    this.focusTasks = const [],
    this.isLoading = false,
    this.onNavigateToMyTasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      padding: AppSpacing.edgeInsetsAll20,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.8),
        borderRadius: AppRadius.r18,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                        borderRadius: AppRadius.r10,
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.bolt_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    AppSpacing.gapW12,
                    Expanded(
                      child: Text(
                        l10n.myActiveFocus,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (onNavigateToMyTasks != null)
                TextButton(
                  onPressed: onNavigateToMyTasks,
                  child: Text(l10n.viewAll),
                ),
            ],
          ),
          AppSpacing.gapH16,
          if (focusTasks.isEmpty && !isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.task_alt_rounded,
                      size: 32,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    AppSpacing.gapH8,
                    Text(
                      l10n.allCaughtUp,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: focusTasks.length,
              separatorBuilder: (context, index) => AppSpacing.gapH10,
              itemBuilder: (context, index) =>
                  FocusTaskTile(task: focusTasks[index]),
            ),
        ],
      ),
    );
  }
}
