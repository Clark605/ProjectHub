import 'package:flutter/material.dart';

import 'package:client/features/kanban/ui/widgets/kanban_column.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';

class KanbanDesktopBoard extends StatelessWidget {
  final Map<TaskStatus, List<TaskDto>> tasksByStatus;
  final bool isArchived;
  final double availableHeight;
  final String? wsAccent;
  final ValueChanged<TaskStatus> onAddTask;
  final ValueChanged<TaskDto> onTaskTap;
  final ValueChanged<TaskDto> onTaskMove;
  final ValueChanged<TaskDto> onTaskDelete;

  const KanbanDesktopBoard({
    super.key,
    required this.tasksByStatus,
    required this.isArchived,
    required this.availableHeight,
    this.wsAccent,
    required this.onAddTask,
    required this.onTaskTap,
    required this.onTaskMove,
    required this.onTaskDelete,
  });

  @override
  Widget build(BuildContext context) {
    final columnHeight = (availableHeight - 32).clamp(300.0, double.infinity);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: TaskStatus.values.map((status) {
          final columnTasks = tasksByStatus[status] ?? [];
          return SizedBox(
            width: 300,
            height: columnHeight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: KanbanColumn(
                status: status,
                tasks: columnTasks,
                isArchived: isArchived,
                activeWorkspaceAccent: wsAccent,
                onAddTask: () => onAddTask(status),
                onTaskTap: onTaskTap,
                onTaskMove: onTaskMove,
                onTaskDelete: onTaskDelete,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
