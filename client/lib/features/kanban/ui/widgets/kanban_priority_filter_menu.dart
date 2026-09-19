import 'package:flutter/material.dart';

import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/ui/extensions/task_priority_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanPriorityFilterMenu extends StatelessWidget {
  final String? selectedPriority;
  final ValueChanged<String?> onPrioritySelected;

  const KanbanPriorityFilterMenu({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSelection = selectedPriority != null && selectedPriority!.isNotEmpty;

    return PopupMenuButton<String>(
      tooltip: l10n?.filterByPriority ?? 'Filter by priority',
      onSelected: (val) => onPrioritySelected(val == 'all' ? null : val),
      child: Chip(
        avatar: Icon(
          Icons.flag_outlined,
          size: 16,
          color: hasSelection ? TaskPriority.fromString(selectedPriority).toColor() : null,
        ),
        label: Text(
          hasSelection ? '${l10n?.taskPriority ?? 'Priority'}: $selectedPriority' : (l10n?.taskPriority ?? 'Priority'),
          style: TextStyle(fontSize: 12, fontWeight: hasSelection ? FontWeight.w600 : FontWeight.normal),
        ),
        deleteIcon: hasSelection ? const Icon(Icons.close_rounded, size: 14) : null,
        onDeleted: hasSelection ? () => onPrioritySelected(null) : null,
      ),
      itemBuilder: (context) => [
        PopupMenuItem(value: 'all', child: Text(l10n?.allPriorities ?? 'All Priorities')),
        ...TaskPriority.values.map(
          (p) => PopupMenuItem(
            value: p.toServerString(),
            child: Row(
              children: [
                Icon(p.toIcon(), size: 16, color: p.toColor()),
                const SizedBox(width: 8),
                Text(l10n != null ? p.localizedName(l10n) : p.toDisplayString()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
