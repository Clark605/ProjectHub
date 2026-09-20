import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/features/kanban/ui/widgets/kanban_column_header.dart';
import 'package:client/features/kanban/ui/widgets/kanban_task_card.dart';
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
  final VoidCallback? onAddTask;
  final ValueChanged<TaskDto>? onTaskTap;
  final ValueChanged<TaskDto>? onTaskMove;
  final ValueChanged<TaskDto>? onTaskDelete;
  final ValueChanged<TagDto>? onTagTap;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.tasks,
    this.isArchived = false,
    this.activeWorkspaceAccent,
    this.onAddTask,
    this.onTaskTap,
    this.onTaskMove,
    this.onTaskDelete,
    this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final statusName = l10n != null
        ? status.localizedName(l10n)
        : status.toDisplayString();
    final accent =
        activeWorkspaceAccent != null &&
            activeWorkspaceAccent!.trim().isNotEmpty
        ? WorkspaceAccent.fromId(
            activeWorkspaceAccent,
          ).resolvedColor(theme.brightness)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5)
            : theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent != null
              ? accent.withValues(alpha: isDark ? 0.35 : 0.25)
              : theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (accent != null)
            Container(
              height: 2.5,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(1.25),
              ),
            ),
          KanbanColumnHeader(
            status: status,
            taskCount: tasks.length,
            isArchived: isArchived,
            accent: accent,
            onAddTask: onAddTask,
          ),
          Expanded(
            child: tasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: isArchived ? null : onAddTask,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
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
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                isArchived
                                    ? (l10n?.noTasksInColumn ?? 'No tasks')
                                    : (l10n != null
                                          ? l10n.addTaskToStatus(statusName)
                                          : 'Add task'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : AppColors.lightTextSecondary,
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
                        task: task,
                        isArchived: isArchived,
                        onTap: () => onTaskTap?.call(task),
                        onMove: () => onTaskMove?.call(task),
                        onDelete: () => onTaskDelete?.call(task),
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
