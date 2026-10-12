import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/ui/widgets/activity_tile.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class RecentActivityCard extends StatelessWidget {
  final List<ActivityEventDto> activities;
  final bool isLoading;
  final int? workspaceId;
  final VoidCallback? onViewAll;

  const RecentActivityCard({
    super.key,
    this.activities = const [],
    this.isLoading = false,
    this.workspaceId,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Container(
      padding: AppSpacing.edgeInsetsAllXl,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.8),
        borderRadius: AppRadius.r18,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withValues(alpha: 0.15),
                  borderRadius: AppRadius.r10,
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.skyBlue,
                  size: AppIconSize.lg,
                ),
              ),
              AppSpacing.gapWMd,
              Expanded(
                child: Text(
                  l10n.teamStream,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (onViewAll != null || workspaceId != null)
                TextButton(
                  onPressed:
                      onViewAll ??
                      () {
                        if (workspaceId != null) {
                          Navigator.pushNamed(
                            context,
                            RouteNames.activityStream,
                            arguments: workspaceId,
                          );
                        }
                      },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                  ),
                  child: Text(l10n.viewAll),
                ),
            ],
          ),
          AppSpacing.gapHLg,
          if (activities.isEmpty && !isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: AppIconSize.xxl,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                    AppSpacing.gapHSm,
                    Text(
                      l10n.noRecentActivity,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.take(5).length,
              separatorBuilder: (context, index) =>
                  Divider(color: theme.colorScheme.outlineVariant, height: 16),
              itemBuilder: (context, index) =>
                  ActivityTile(activity: activities[index]),
            ),
        ],
      ),
    );
  }
}
