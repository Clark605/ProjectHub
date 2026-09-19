import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.assignee ?? 'Assignee',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String?>(
          initialValue: editAssigneeId,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surfaceContainer,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          hint: Text(l10n?.unassigned ?? 'Unassigned'),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(l10n?.unassigned ?? 'Unassigned'),
            ),
            if (editAssigneeId != null &&
                !members.any((m) => m.userId == editAssigneeId))
              DropdownMenuItem<String?>(
                value: editAssigneeId,
                child: Text(
                  taskAssigneeName ??
                      (l10n?.assignedMember ?? 'Assigned Member'),
                ),
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
        const SizedBox(height: 16),
        Text(
          l10n?.dueDate ?? 'Due Date',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onPickDueDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    editDueDate != null
                        ? DateFormat('MMM d, yyyy').format(editDueDate!)
                        : (l10n?.noDueDate ?? 'No due date'),
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
