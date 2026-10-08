import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/ui/widgets/board/kanban_screen_actions.dart';
import 'package:client/features/kanban/ui/widgets/card/kanban_task_card_footer.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tags/ui/widgets/tag_chip.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/extensions/task_priority_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanTaskCard extends StatelessWidget {
  final TaskDto task;
  final bool isArchived;
  final VoidCallback? onTap;
  final VoidCallback? onMove;
  final VoidCallback? onDelete;
  final ValueChanged<TagDto>? onTagTap;

  const KanbanTaskCard({
    super.key,
    required this.task,
    this.isArchived = false,
    this.onTap,
    this.onMove,
    this.onDelete,
    this.onTagTap,
  });

  KanbanCubit? _tryGetCubit(BuildContext context) {
    try {
      return context.read<KanbanCubit>();
    } catch (_) {
      // Allows rendering task card in isolated component tests without KanbanCubit
      return null;
    }
  }

  void _handleTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }
    final cubit = _tryGetCubit(context);
    if (cubit == null) return;
    KanbanScreenActions.openTaskDetail(
      context,
      task: task,
      isArchived: isArchived,
      members: cubit.members,
      cubit: cubit,
    );
  }

  void _handleMove(BuildContext context) {
    if (onMove != null) {
      onMove!();
      return;
    }
    final cubit = _tryGetCubit(context);
    if (cubit == null) return;
    KanbanScreenActions.openMoveToStatus(context, task: task, cubit: cubit);
  }

  void _handleDelete(BuildContext context) {
    if (onDelete != null) {
      onDelete!();
      return;
    }
    final cubit = _tryGetCubit(context);
    if (cubit == null) return;
    KanbanScreenActions.confirmAndDeleteTask(context, task, cubit);
  }

  void _handleTagTap(BuildContext context, TagDto tag) {
    if (onTagTap != null) {
      onTagTap!(tag);
      return;
    }
    final cubit = _tryGetCubit(context);
    if (cubit == null) return;
    final currentTag = cubit.tagFilter;
    cubit.setFilter(
      tagId: tag.id == currentTag ? null : tag.id,
      clearTag: tag.id == currentTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final priorityColor = task.priorityEnum.toColor();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: AppRadius.r12,
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.pureBlack.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.r12,
          onTap: () => _handleTap(context),
          onLongPress: isArchived ? null : () => _handleMove(context),
          child: ClipRRect(
            borderRadius: AppRadius.r12,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  width: 4,
                  child: ColoredBox(color: priorityColor),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              task.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!isArchived)
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                size: 20,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 48,
                                minHeight: 48,
                              ),
                              onSelected: (action) {
                                if (action == 'move') _handleMove(context);
                                if (action == 'delete') _handleDelete(context);
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'move',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.drive_file_move_outlined,
                                        size: 18,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(l10n.moveTask),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.delete_outline_rounded,
                                        size: 18,
                                        color: AppColors.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.delete,
                                        style: const TextStyle(
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
                      if (task.tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: task.tags
                              .map(
                                (t) => TagChip(
                                  tag: t,
                                  onTap: () => _handleTagTap(context, t),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 10),
                      KanbanTaskCardFooter(
                        priority: task.priorityEnum,
                        dueDate: task.dueDate,
                        isOverdue: task.isOverdue,
                        assigneeName: task.assigneeName,
                        assigneeId: task.assigneeId,
                        commentCount: task.commentCount,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
