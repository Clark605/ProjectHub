import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/ui/widgets/activity_event_spans.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ActivityTile extends StatelessWidget {
  final ActivityEventDto activity;

  const ActivityTile({super.key, required this.activity});

  Color _getColorForEvent(String type) {
    if (type.contains('Task')) return AppColors.electricViolet;
    if (type.contains('Project')) return AppColors.skyBlue;
    if (type.contains('Member')) return AppColors.success;
    return AppColors.warning;
  }

  String _formatRelativeTime(DateTime dateTime, AppLocalizations? l10n) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return l10n?.timeJustNow ?? 'Just now';
    if (diff.inMinutes < 60) {
      return l10n != null ? l10n.timeMinutesAgo(diff.inMinutes) : '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return l10n != null ? l10n.timeHoursAgo(diff.inHours) : '${diff.inHours}h ago';
    }
    if (diff.inDays < 7) {
      return l10n != null ? l10n.timeDaysAgo(diff.inDays) : '${diff.inDays}d ago';
    }
    return DateFormat('MMM d').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final avatarColor = _getColorForEvent(activity.eventType);
    final avatarText = activity.actorName.isNotEmpty
        ? activity.actorName.trim().substring(0, 1).toUpperCase()
        : 'U';
    final timeStr = _formatRelativeTime(activity.createdAt, l10n);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: avatarColor.withValues(alpha: 0.2),
          child: Text(
            avatarText,
            style: TextStyle(
              color: avatarColor,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              children: [
                TextSpan(
                  text: '${activity.actorName} ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                ...buildActivityEventSpans(activity, theme, l10n),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          timeStr,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
