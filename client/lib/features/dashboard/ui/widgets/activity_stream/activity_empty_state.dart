import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class ActivityEmptyState extends StatelessWidget {
  const ActivityEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: AppSpacing.edgeInsetsAllXxxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: AppIconSize.display,
              color: theme.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.5,
              ),
            ),
            AppSpacing.gapHMd,
            Text(
              l10n.noRecentActivity,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
