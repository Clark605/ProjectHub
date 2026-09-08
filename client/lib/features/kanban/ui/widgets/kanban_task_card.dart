import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

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
    final priorityColor = task.priorityEnum.toColor();
    final isOverdue = task.isOverdue;

    return Hero(
      tag: 'task_${task.id}',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceContainer : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.border : AppColors.lightBorder,
            width: 1,
          ),
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
                // Priority Accent Indicator
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
                        // Card Header: Title & Context Menu
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isArchived &&
                                (onMove != null || onDelete != null))
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  size: 18,
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                                onSelected: (action) {
                                  if (action == 'move') {
                                    onMove?.call();
                                  } else if (action == 'delete') {
                                    onDelete?.call();
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (onMove != null)
                                    const PopupMenuItem(
                                      value: 'move',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.drive_file_move_outlined,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text('Move to...'),
                                        ],
                                      ),
                                    ),
                                  if (onDelete != null)
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete_outline_rounded,
                                            size: 18,
                                            color: AppColors.error,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: AppColors.error,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Card Footer: Due Date Chip & Assignee Avatar
                        Row(
                          children: [
                            // Due Date Chip
                            if (task.dueDate != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isOverdue
                                      ? AppColors.error.withValues(alpha: 0.15)
                                      : (isDark
                                            ? Colors.white10
                                            : Colors.black.withValues(
                                                alpha: 0.05,
                                              )),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      size: 11,
                                      color: isOverdue
                                          ? AppColors.error
                                          : (isDark
                                                ? AppColors.textSecondary
                                                : AppColors.lightTextSecondary),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateFormat('MMM d').format(task.dueDate!),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isOverdue
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isOverdue
                                            ? AppColors.error
                                            : (isDark
                                                  ? AppColors.textSecondary
                                                  : AppColors
                                                        .lightTextSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Spacer(),

                            // Assignee Avatar
                            _buildAssigneeAvatar(context),
                          ],
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

  Widget _buildAssigneeAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final name = task.assigneeName;

    if (name != null && name.trim().isNotEmpty) {
      final initial = name.trim().substring(0, 1).toUpperCase();
      return Tooltip(
        message: 'Assigned to $name',
        child: CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.electricViolet.withValues(alpha: 0.2),
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.electricViolet,
            ),
          ),
        ),
      );
    }

    return Tooltip(
      message: 'Unassigned',
      child: CircleAvatar(
        radius: 12,
        backgroundColor: isDark
            ? Colors.white10
            : Colors.black.withValues(alpha: 0.06),
        child: Icon(
          Icons.person_outline_rounded,
          size: 14,
          color: isDark
              ? AppColors.textSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}
