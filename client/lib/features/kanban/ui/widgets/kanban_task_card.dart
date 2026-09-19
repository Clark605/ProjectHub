import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/kanban/ui/widgets/kanban_task_card_footer.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/extensions/task_priority_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanTaskCard extends StatelessWidget {
  final TaskDto task;
  final bool isArchived;
  final VoidCallback? onTap;
  final VoidCallback? onMove;
  final VoidCallback? onDelete;

  const KanbanTaskCard({
    super.key,
    required this.task,
    this.isArchived = false,
    this.onTap,
    this.onMove,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final priorityColor = task.priorityEnum.toColor();

    return Hero(
      tag: 'task_${task.id}',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            onLongPress: isArchived ? null : onMove,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!isArchived)
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onSelected: (action) {
                                    if (action == 'move') onMove?.call();
                                    if (action == 'delete') onDelete?.call();
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'move',
                                      child: Row(
                                        children: [
                                          Icon(Icons.drive_file_move_outlined, size: 18, color: theme.colorScheme.onSurface),
                                          const SizedBox(width: 8),
                                          Text(l10n?.moveTask ?? 'Move'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                                          const SizedBox(width: 8),
                                          Text(l10n?.delete ?? 'Delete', style: const TextStyle(color: AppColors.error)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          KanbanTaskCardFooter(
                            dueDate: task.dueDate,
                            isOverdue: task.isOverdue,
                            assigneeName: task.assigneeName,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
