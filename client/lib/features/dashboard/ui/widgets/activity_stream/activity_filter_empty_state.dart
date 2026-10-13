import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class ActivityFilterEmptyState extends StatelessWidget {
  final VoidCallback onClearFilters;

  const ActivityFilterEmptyState({
    super.key,
    required this.onClearFilters,
  });

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
              Icons.filter_alt_off_rounded,
              size: AppIconSize.display,
              color: theme.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.5,
              ),
            ),
            AppSpacing.gapHMd,
            Text(
              l10n.noMatchingActivities,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.gapHLg,
            ElevatedButton.icon(
              key: const Key('activity_stream_reset_filters_button'),
              onPressed: onClearFilters,
              icon: const Icon(Icons.clear_all_rounded),
              label: Text(l10n.clearFilters),
            ),
          ],
        ),
      ),
    );
  }
}
