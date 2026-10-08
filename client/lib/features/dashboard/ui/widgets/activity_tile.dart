import 'package:flutter/material.dart';

import 'package:client/core/utils/date_formatter.dart';
import 'package:client/core/widgets/app_avatar.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/ui/widgets/activity_event_spans.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ActivityTile extends StatelessWidget {
  final ActivityEventDto activity;

  const ActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final timeStr = DateFormatter.formatRelativeTime(
      activity.createdAt,
      context: context,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(name: activity.actorName, userId: activity.actorId, size: 28),
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
          ),
        ),
      ],
    );
  }
}
