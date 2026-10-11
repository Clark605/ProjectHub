import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/date_formatter.dart';

import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class TaskDetailAssigneeDueFields extends StatelessWidget {
  final List<MemberDto> members;
  final String? editAssigneeId;
  final String? taskAssigneeName;
  final DateTime? editDueDate;
  final ValueChanged<String?> onAssigneeChanged;
  final VoidCallback onPickDueDate;
  final VoidCallback onClearDueDate;

  const TaskDetailAssigneeDueFields({
    super.key,
    required this.members,
    required this.editAssigneeId,
    required this.taskAssigneeName,
    required this.editDueDate,
    required this.onAssigneeChanged,
    required this.onPickDueDate,
    required this.onClearDueDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.assignee,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.gapH8,
        DropdownButtonFormField<String?>(
          initialValue: editAssigneeId,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: AppRadius.r12,
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.r12,
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          hint: Text(l10n.unassigned),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(l10n.unassigned),
            ),
            if (editAssigneeId != null &&
                !members.any((m) => m.userId == editAssigneeId))
              DropdownMenuItem<String?>(
                value: editAssigneeId,
                child: Text(taskAssigneeName ?? (l10n.assignedMember)),
              ),
            ...members.map(
              (m) => DropdownMenuItem<String?>(
                value: m.userId,
                child: Text(m.name),
              ),
            ),
          ],
          onChanged: onAssigneeChanged,
        ),
        AppSpacing.gapH16,
        Text(
          l10n.dueDate,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        AppSpacing.gapH8,
        InkWell(
          onTap: onPickDueDate,
          borderRadius: AppRadius.r12,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: AppRadius.r12,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                AppSpacing.gapW8,
                Expanded(
                  child: Text(
                    editDueDate != null
                        ? DateFormatter.formatDate(
                            editDueDate!,
                            context: context,
                          )
                        : (l10n.noDueDate),
                  ),
                ),
                if (editDueDate != null)
                  GestureDetector(
                    onTap: onClearDueDate,
                    child: const Icon(Icons.close_rounded, size: 16),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
