import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/features/kanban/ui/widgets/kanban_task_card.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
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
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final statusColor = status.toColor();
    final statusName = l10n != null
        ? status.localizedName(l10n)
        : status.toDisplayString();
    final accent =
        activeWorkspaceAccent != null && activeWorkspaceAccent!.trim().isNotEmpty
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
          // Column Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
            child: Row(
              children: [
                // Status Color Dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),

                // Status Title
                Flexible(
                  child: Text(
                    statusName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),

                // Count Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: accent != null
                        ? accent.withValues(alpha: 0.12)
                        : (isDark ? Colors.white12 : Colors.black12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accent ??
                          (isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary),
                    ),
                  ),
                ),
                const Spacer(),

                // Add Task to this Column
                if (!isArchived && onAddTask != null)
                  IconButton(
                    icon: const Icon(Icons.add_rounded, size: 20),
                    tooltip: l10n != null
                        ? l10n.addTaskToStatus(statusName)
                        : 'Add task to $statusName',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    onPressed: onAddTask,
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Task Cards List
          Expanded(
            child: tasks.isEmpty
                ? LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  status.toIcon(),
                                  size: 28,
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black26,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n?.noTasksInColumn ??
                                      'No tasks in this column',
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
