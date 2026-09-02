import 'package:flutter/material.dart';

import 'package:client/features/tasks/ui/widgets/task_card_widget.dart';

class TaskSectionWidget extends StatelessWidget {
  final String title;
  final Color color;
  final List<UserTaskItem> tasks;
  final ValueChanged<UserTaskItem>? onTaskToggle;

  const TaskSectionWidget({
    super.key,
    required this.title,
    required this.color,
    required this.tasks,
    this.onTaskToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${tasks.length}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tasks.map((task) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TaskCardWidget(
                task: task,
                onStatusToggle: () => onTaskToggle?.call(task),
              ),
            )),
      ],
    );
  }
}
