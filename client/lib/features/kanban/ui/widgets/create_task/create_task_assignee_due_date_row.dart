import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';
import 'package:client/core/utils/date_formatter.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class CreateTaskAssigneeDueDateRow extends StatelessWidget {
  final List<MemberDto> members;
  final String? selectedAssigneeId;
  final DateTime? selectedDueDate;
  final ValueChanged<String?> onAssigneeChanged;
  final VoidCallback onPickDueDate;
  final VoidCallback onClearDueDate;

  const CreateTaskAssigneeDueDateRow({
    super.key,
    required this.members,
    required this.selectedAssigneeId,
    required this.selectedDueDate,
    required this.onAssigneeChanged,
    required this.onPickDueDate,
    required this.onClearDueDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.assignee,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String?>(
                initialValue: selectedAssigneeId,
                isExpanded: true,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainer,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.r12,
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.r12,
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                ),
                hint: Text(
                  l10n.unassigned,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      l10n.unassigned,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (selectedAssigneeId != null &&
                      !members.any((m) => m.userId == selectedAssigneeId))
                    DropdownMenuItem<String?>(
                      value: selectedAssigneeId,
                      child: Text(
                        l10n.assignedMember,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ...members.map(
                    (m) => DropdownMenuItem<String?>(
                      value: m.userId,
                      child: Text(
                        m.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
                onChanged: onAssigneeChanged,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dueDate,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: onPickDueDate,
                borderRadius: AppRadius.r12,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          selectedDueDate != null
                              ? DateFormatter.formatDate(
                                  selectedDueDate!,
                                  context: context,
                                )
                              : (l10n.noDueDate),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: selectedDueDate != null
                                ? null
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (selectedDueDate != null)
                        GestureDetector(
                          onTap: onClearDueDate,
                          child: const Icon(Icons.close_rounded, size: 16),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
