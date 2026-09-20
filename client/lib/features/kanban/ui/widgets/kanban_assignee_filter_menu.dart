import 'package:flutter/material.dart';

import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanAssigneeFilterMenu extends StatelessWidget {
  final String? selectedAssignee;
  final List<MemberDto> members;
  final ValueChanged<String?> onAssigneeSelected;

  const KanbanAssigneeFilterMenu({
    super.key,
    required this.selectedAssignee,
    required this.members,
    required this.onAssigneeSelected,
  });

  String _resolveAssigneeLabel(String? assigneeId, AppLocalizations? l10n) {
    if (assigneeId == null || assigneeId.isEmpty || assigneeId == 'all') {
      return l10n?.assignee ?? 'Assignee';
    }
    if (assigneeId == 'unassigned') return l10n?.unassigned ?? 'Unassigned';
    final member = members.where((m) => m.userId == assigneeId).firstOrNull;
    return member != null ? member.name : (l10n?.assignee ?? 'Assignee');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSelection =
        selectedAssignee != null && selectedAssignee!.isNotEmpty;

    return PopupMenuButton<String>(
      tooltip: l10n?.filterByAssignee ?? 'Filter by assignee',
      onSelected: (val) => onAssigneeSelected(val == 'all' ? null : val),
      child: Chip(
        avatar: const Icon(Icons.person_outline_rounded, size: 16),
        label: Text(
          _resolveAssigneeLabel(selectedAssignee, l10n),
          style: TextStyle(
            fontSize: 12,
            fontWeight: hasSelection ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        deleteIcon: hasSelection
            ? const Icon(Icons.close_rounded, size: 14)
            : null,
        onDeleted: hasSelection ? () => onAssigneeSelected(null) : null,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'all',
          child: Text(l10n?.allAssignees ?? 'All Assignees'),
        ),
        PopupMenuItem(
          value: 'unassigned',
          child: Text(l10n?.unassigned ?? 'Unassigned'),
        ),
        ...members.map(
          (m) => PopupMenuItem(value: m.userId, child: Text(m.name)),
        ),
      ],
    );
  }
}
