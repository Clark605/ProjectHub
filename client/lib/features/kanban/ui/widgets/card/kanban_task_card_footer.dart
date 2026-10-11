import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_typography.dart';
import 'package:client/core/utils/date_formatter.dart';
import 'package:client/core/widgets/app_avatar.dart';
import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/ui/extensions/task_priority_ui.dart';
import 'package:client/l10n/generated/app_localizations.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

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
    final l10n = context.l10n;

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
                    horizontal: AppSpacing.s6,
                    vertical: AppSpacing.xxs,
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
                      const SizedBox(width: AppSpacing.s3),
                      Flexible(
                        child: Text(
                          priority!.localizedName(l10n),
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.badge.copyWith(
                            color: priority!.toColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (dueDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s6,
                    vertical: AppSpacing.xxs,
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
                      AppSpacing.gapW4,
                      Flexible(
                        child: Text(
                          DateFormatter.formatShortDate(
                            dueDate!,
                            context: context,
                          ),
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.badge.copyWith(
                            fontWeight: isOverdue
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isOverdue
                                ? AppColors.error
                                : theme.colorScheme.onSurfaceVariant,
                          ),
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
                    const SizedBox(width: AppSpacing.s3),
                    Text(
                      '$commentCount',
                      style: theme.textTheme.caption.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        AppSpacing.gapW8,
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
        child: AppAvatar(name: name, size: 24),
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
