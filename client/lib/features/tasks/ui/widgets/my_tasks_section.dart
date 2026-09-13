import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/widgets/my_task_list_tile.dart';

class MyTasksSection extends StatelessWidget {
  final String emoji;
  final String title;
  final List<TaskDto> tasks;
  final bool isCollapsible;
  final bool isCollapsed;
  final String? activeWorkspaceAccent;
  final VoidCallback? onToggleCollapse;
  final ValueChanged<TaskDto>? onTaskTap;
  final ValueChanged<TaskDto>? onTaskStatusTap;

  const MyTasksSection({
    super.key,
    required this.emoji,
    required this.title,
    required this.tasks,
    this.isCollapsible = false,
    this.isCollapsed = false,
    this.activeWorkspaceAccent,
    this.onToggleCollapse,
    this.onTaskTap,
    this.onTaskStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent =
        activeWorkspaceAccent != null && activeWorkspaceAccent!.trim().isNotEmpty
            ? WorkspaceAccent.fromId(
                activeWorkspaceAccent,
              ).resolvedColor(theme.brightness)
            : null;

    if (tasks.isEmpty && !isCollapsible) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        InkWell(
          onTap: isCollapsible ? onToggleCollapse : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 8),
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
                if (isCollapsible)
                  Icon(
                    isCollapsed
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    size: 20,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Section Body
        if (!isCollapsed) ...[
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Text(
                'No tasks in this section',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondary
                      : AppColors.lightTextSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ...tasks.map(
              (task) => MyTaskListTile(
                task: task,
                onTap: () => onTaskTap?.call(task),
                onStatusTap: () => onTaskStatusTap?.call(task),
              ),
            ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}
