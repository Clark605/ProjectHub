import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:flutter/material.dart';

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

  String _resolveAssigneeLabel(String? assigneeId, AppLocalizations l10n) {
    if (assigneeId == null || assigneeId.isEmpty || assigneeId == 'all') {
      return l10n.assignee;
    }
    if (assigneeId == 'unassigned') return l10n.unassigned;
    final member = members.where((m) => m.userId == assigneeId).firstOrNull;
    return member != null ? member.name : l10n.assignee;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasSelection =
        selectedAssignee != null && selectedAssignee!.isNotEmpty;

    return PopupMenuButton<String>(
      tooltip: l10n.filterByAssignee,
      onSelected: (val) => onAssigneeSelected(val == 'all' ? null : val),
      child: Chip(
        avatar: const Icon(Icons.person_outline_rounded, size: AppIconSize.sm),
        label: Text(
          _resolveAssigneeLabel(selectedAssignee, l10n),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: hasSelection ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        deleteIcon: hasSelection
            ? const Icon(Icons.close_rounded, size: AppIconSize.xs)
            : null,
        onDeleted: hasSelection ? () => onAssigneeSelected(null) : null,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'all', child: Text(l10n.allAssignees)),
        PopupMenuItem(value: 'unassigned', child: Text(l10n.unassigned)),
        ...members.map(
          (m) => PopupMenuItem(value: m.userId, child: Text(m.name)),
        ),
      ],
    );
  }
}
