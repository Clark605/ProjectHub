import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/ui/extensions/task_status_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanColumnHeader extends StatelessWidget {
  final TaskStatus status;
  final int taskCount;
  final bool isArchived;
  final Color? accent;
  final VoidCallback? onAddTask;

  const KanbanColumnHeader({
    super.key,
    required this.status,
    required this.taskCount,
    required this.isArchived,
    this.accent,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final statusColor = status.toColor();
    final statusName = l10n != null ? status.localizedName(l10n) : status.toDisplayString();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              statusName,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: accent != null ? accent!.withValues(alpha: 0.12) : (isDark ? Colors.white12 : Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$taskCount',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accent ?? (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ),
          const Spacer(),
          if (!isArchived && onAddTask != null)
            IconButton(
              icon: const Icon(Icons.add_rounded, size: 20),
              tooltip: l10n != null ? l10n.addTaskToStatus(statusName) : 'Add task to $statusName',
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(6),
              onPressed: onAddTask,
            ),
        ],
      ),
    );
  }
}
