import 'package:flutter/material.dart';

import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/ui/extensions/task_priority_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class TaskPrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onSelected;

  const TaskPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.taskPriority ?? 'Priority',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: TaskPriority.values.map((priority) {
            final isSelected = priority == selectedPriority;
            return ChoiceChip(
              selected: isSelected,
              avatar: Icon(
                priority.toIcon(),
                size: 16,
                color: isSelected ? Colors.white : priority.toColor(),
              ),
              label: Text(
                l10n != null
                    ? priority.localizedName(l10n)
                    : priority.toDisplayString(),
              ),
              selectedColor: priority.toColor(),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected) {
                  onSelected(priority);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
