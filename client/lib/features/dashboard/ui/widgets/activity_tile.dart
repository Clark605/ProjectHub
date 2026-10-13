import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_avatar_size.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/utils/date_formatter.dart';
import 'package:client/core/widgets/app_avatar.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/ui/widgets/activity_event_spans.dart';
import 'package:flutter/material.dart';

class ActivityTile extends StatelessWidget {
  final ActivityEventDto activity;

  const ActivityTile({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final timeStr = DateFormatter.formatRelativeTime(
      activity.createdAt,
      context: context,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(name: activity.actorName, size: AppAvatarSize.sm),
        AppSpacing.gapWSm,
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              children: [
                TextSpan(
                  text: '${activity.actorName} ',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ...buildActivityEventSpans(activity, theme, l10n),
              ],
            ),
          ),
        ),
        AppSpacing.gapWSm,
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
