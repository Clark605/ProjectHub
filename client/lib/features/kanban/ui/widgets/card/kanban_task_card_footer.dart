import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/utils/date_formatter.dart';
import 'package:client/core/widgets/app_avatar.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/ui/extensions/task_priority_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanTaskCardFooter extends StatelessWidget {
  final TaskPriority? priority;
  final DateTime? dueDate;
  final bool isOverdue;
  final String? assigneeName;
  final String? assigneeId;
  final int commentCount;

  const KanbanTaskCardFooter({
    super.key,
    this.priority,
    this.dueDate,
    required this.isOverdue,
    this.assigneeName,
    this.assigneeId,
    this.commentCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (priority != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: priority!.toColor().withValues(
                      alpha: isDark ? 0.2 : 0.12,
                    ),
                    borderRadius: AppRadius.r6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        priority!.toIcon(),
                        size: 11,
                        color: priority!.toColor(),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        priority!.localizedName(l10n),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: priority!.toColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              if (dueDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? AppColors.error.withValues(alpha: 0.15)
                        : (isDark
                              ? AppColors.pureWhite.withValues(alpha: 0.1)
                              : AppColors.pureBlack.withValues(alpha: 0.05)),
                    borderRadius: AppRadius.r6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 11,
                        color: isOverdue
                            ? AppColors.error
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatShortDate(
                          dueDate!,
                          context: context,
                        ),
                        style: TextStyle(
                          fontWeight: isOverdue
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isOverdue
                              ? AppColors.error
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              if (commentCount > 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$commentCount',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildAvatar(context, theme, isDark, l10n),
      ],
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final name = assigneeName?.trim();
    if (name != null && name.isNotEmpty) {
      return Tooltip(
        message: l10n.assignedToUser(name),
        child: AppAvatar(name: name, userId: assigneeId, size: 24),
      );
    }
    return Tooltip(
      message: l10n.unassigned,
      child: CircleAvatar(
        radius: 12,
        backgroundColor: isDark
            ? AppColors.pureWhite.withValues(alpha: 0.1)
            : AppColors.pureBlack.withValues(alpha: 0.06),
        child: Icon(
          Icons.person_outline_rounded,
          size: 13,
          color: AppColors.textSecondaryColor(isDark),
        ),
      ),
    );
  }
}
