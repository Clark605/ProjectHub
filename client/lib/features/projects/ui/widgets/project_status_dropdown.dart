import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/projects/data/models/project_status.dart';

class ProjectStatusDropdown extends StatelessWidget {
  const ProjectStatusDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final String value;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStatus = ProjectStatus.fromString(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<ProjectStatus>(
          initialValue: currentStatus,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled
                ? AppColors.surfaceContainerHigh
                : AppColors.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
          ),
          items: ProjectStatus.values.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status.toDisplayString()),
            );
          }).toList(),
          onChanged: enabled
              ? (status) => onChanged(status?.toDisplayString())
              : null,
        ),
      ],
    );
  }
}
