import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/ui/extensions/task_priority_ui.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

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
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.taskPriority,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.gapHSm,
        Wrap(
          spacing: AppSpacing.sm,
          children: TaskPriority.values.map((priority) {
            final isSelected = priority == selectedPriority;
            return ChoiceChip(
              selected: isSelected,
              avatar: Icon(
                priority.toIcon(),
                size: AppIconSize.sm,
                color: isSelected ? AppColors.pureWhite : priority.toColor(),
              ),
              label: Text(priority.localizedName(l10n)),
              selectedColor: priority.toColor(),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.pureWhite : null,
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
