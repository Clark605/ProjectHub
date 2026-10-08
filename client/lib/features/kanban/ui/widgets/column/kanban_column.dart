import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/ui/widgets/board/kanban_screen_actions.dart';
import 'package:client/features/kanban/ui/widgets/card/kanban_task_card.dart';
import 'package:client/features/kanban/ui/widgets/column/kanban_column_header.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanColumn extends StatelessWidget {
  final TaskStatus status;
  final List<TaskDto> tasks;
  final bool isArchived;
  final String? activeWorkspaceAccent;
  final Color? accent;
  final VoidCallback? onAddTask;
  final ValueChanged<TaskDto>? onTaskTap;
  final ValueChanged<TaskDto>? onTaskMove;
  final ValueChanged<TaskDto>? onTaskDelete;
  final ValueChanged<TagDto>? onTagTap;
  final bool showHeader;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.tasks,
    this.isArchived = false,
    this.activeWorkspaceAccent,
    this.accent,
    this.onAddTask,
    this.onTaskTap,
    this.onTaskMove,
    this.onTaskDelete,
    this.onTagTap,
    this.showHeader = true,
  });

  KanbanCubit? _tryGetCubit(BuildContext context) {
    try {
      return context.read<KanbanCubit>();
    } catch (_) {
      // Allows rendering kanban column in isolated component tests without KanbanCubit
      return null;
    }
  }

  void _handleAddTask(BuildContext context) {
    if (onAddTask != null) {
      onAddTask!();
      return;
    }
    final cubit = _tryGetCubit(context);
    final pId = cubit?.projectId;
    if (cubit != null && pId != null) {
      KanbanScreenActions.openCreateTask(
        context,
        projectId: pId,
        members: cubit.members,
        cubit: cubit,
        status: status.toServerString(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final statusName = status.localizedName(l10n);
    final columnAccent =
        accent ??
        WorkspaceAccent.resolve(activeWorkspaceAccent, theme.brightness);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.7),
        borderRadius: AppRadius.r16,
        border: Border.all(
          color: columnAccent != null
              ? columnAccent.withValues(alpha: isDark ? 0.35 : 0.25)
              : theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (columnAccent != null)
            Container(
              height: 2.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: columnAccent.withValues(alpha: 0.8),
                borderRadius: const BorderRadius.all(Radius.circular(1.25)),
              ),
            ),
          if (showHeader)
            KanbanColumnHeader(
              status: status,
              taskCount: tasks.length,
              isArchived: isArchived,
              accent: columnAccent,
              onAddTask: isArchived ? null : () => _handleAddTask(context),
            )
          else
            const SizedBox(height: 8),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        borderRadius: AppRadius.r12,
                        onTap: isArchived
                            ? null
                            : () => _handleAddTask(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.r12,
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                              strokeAlign: BorderSide.strokeAlignCenter,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isArchived
                                    ? Icons.inbox_outlined
                                    : Icons.add_circle_outline_rounded,
                                size: 24,
                                color: AppColors.textSecondaryColor(isDark),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isArchived
                                    ? l10n.noTasksInColumn
                                    : l10n.addTaskToStatus(statusName),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.textSecondaryColor(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return KanbanTaskCard(
                        key: ValueKey(task.id),
                        task: task,
                        isArchived: isArchived,
                        onTap: onTaskTap != null
                            ? () => onTaskTap!(task)
                            : null,
                        onMove: onTaskMove != null
                            ? () => onTaskMove!(task)
                            : null,
                        onDelete: onTaskDelete != null
                            ? () => onTaskDelete!(task)
                            : null,
                        onTagTap: onTagTap,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
