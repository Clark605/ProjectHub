import 'package:flutter/material.dart';

import 'package:client/core/widgets/app_empty_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanEmptyState extends StatelessWidget {
  final bool isArchived;
  final VoidCallback? onCreateTask;

  const KanbanEmptyState({
    super.key,
    this.isArchived = false,
    this.onCreateTask,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppEmptyState(
      icon: Icons.view_kanban_outlined,
      title: isArchived
          ? (l10n?.noTasksArchived ?? 'No Tasks')
          : (l10n?.boardIsEmpty ?? 'Board is Empty'),
      description: isArchived
          ? (l10n?.noTasksArchivedSubtitle ??
                'This project is archived and has no tasks recorded.')
          : (l10n?.boardIsEmptySubtitle ??
                'Start organizing your workflow by creating the first task for this project.'),
      ctaText: !isArchived && onCreateTask != null
          ? (l10n?.createFirstTask ?? 'Create First Task')
          : null,
      onCtaPressed: !isArchived ? onCreateTask : null,
    );
  }
}
