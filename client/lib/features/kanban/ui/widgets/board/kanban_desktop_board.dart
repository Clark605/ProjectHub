import 'package:flutter/material.dart';

import 'package:client/features/kanban/ui/widgets/column/kanban_column.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/core/theme/app_spacing.dart';

class KanbanDesktopBoard extends StatelessWidget {
  final Map<TaskStatus, List<TaskDto>> tasksByStatus;
  final bool isArchived;
  final double availableHeight;
  final String? wsAccent;
  final ValueChanged<TaskStatus>? onAddTask;

  const KanbanDesktopBoard({
    super.key,
    required this.tasksByStatus,
    required this.isArchived,
    required this.availableHeight,
    this.wsAccent,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final columnHeight = (availableHeight - 32).clamp(300.0, double.infinity);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: AppSpacing.edgeInsetsAllLg,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: TaskStatus.values.map((status) {
          final columnTasks = tasksByStatus[status] ?? [];
          return SizedBox(
            width: 300,
            height: columnHeight,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg),
              child: KanbanColumn(
                status: status,
                tasks: columnTasks,
                isArchived: isArchived,
                activeWorkspaceAccent: wsAccent,
                onAddTask: onAddTask != null ? () => onAddTask!(status) : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
