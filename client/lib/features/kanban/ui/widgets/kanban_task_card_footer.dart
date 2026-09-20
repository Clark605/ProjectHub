import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanTaskCardFooter extends StatelessWidget {
  final DateTime? dueDate;
  final bool isOverdue;
  final String? assigneeName;
  final int commentCount;

  const KanbanTaskCardFooter({
    super.key,
    this.dueDate,
    required this.isOverdue,
    this.assigneeName,
    this.commentCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        if (dueDate != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isOverdue
                  ? AppColors.error.withValues(alpha: 0.15)
                  : (isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(6),
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
                  DateFormat('MMM d').format(dueDate!),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                    color: isOverdue
                        ? AppColors.error
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        if (commentCount > 0) ...[
          const SizedBox(width: 6),
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
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
        const Spacer(),
        _buildAvatar(context, theme, isDark, l10n),
      ],
    );
  }

  Widget _buildAvatar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    final name = assigneeName;
    if (name != null && name.trim().isNotEmpty) {
      final initial = name.trim().substring(0, 1).toUpperCase();
      return Tooltip(
        message: 'Assigned to $name',
        child: CircleAvatar(
          radius: 12,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      );
    }
    return Tooltip(
      message: l10n?.unassigned ?? 'Unassigned',
      child: CircleAvatar(
        radius: 12,
        backgroundColor: isDark
            ? Colors.white10
            : Colors.black.withValues(alpha: 0.06),
        child: Icon(
          Icons.person_outline_rounded,
          size: 13,
          color: isDark
              ? AppColors.textSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}
