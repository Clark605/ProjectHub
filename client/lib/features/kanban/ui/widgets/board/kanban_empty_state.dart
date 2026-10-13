import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';

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
    final l10n = context.l10n;

    return AppEmptyState(
      icon: Icons.view_kanban_outlined,
      title: isArchived ? (l10n.noTasksArchived) : (l10n.boardIsEmpty),
      description: isArchived
          ? (l10n.noTasksArchivedSubtitle)
          : (l10n.boardIsEmptySubtitle),
      ctaText: !isArchived && onCreateTask != null
          ? (l10n.createFirstTask)
          : null,
      onCtaPressed: !isArchived ? onCreateTask : null,
    );
  }
}
