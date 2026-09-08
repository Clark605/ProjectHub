import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';

class RecentActivityCard extends StatelessWidget {
  final List<ActivityEventDto> activities;
  final bool isLoading;

  const RecentActivityCard({
    super.key,
    this.activities = const [],
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
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
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.skyBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.skyBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Team Presence & Stream',
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
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty && !isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 32,
                      color: AppColors.textTertiary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No recent activity yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
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
              itemCount: activities.take(6).length,
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.border, height: 16),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return _ActivityTile(activity: activity);
              },
            ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityEventDto activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarColor = _getColorForEvent(activity.eventType);
    final avatarText = activity.actorName.isNotEmpty
        ? activity.actorName.trim().substring(0, 1).toUpperCase()
        : 'U';
    final actionDescription = _describeEvent(activity);
    final timeStr = _formatRelativeTime(activity.createdAt);

    return Row(
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
                color: AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: '${activity.actorName} ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: actionDescription,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          timeStr,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Color _getColorForEvent(String type) {
    if (type.contains('Task')) return AppColors.electricViolet;
    if (type.contains('Project')) return AppColors.skyBlue;
    if (type.contains('Member')) return AppColors.success;
    return AppColors.warning;
  }

  String _describeEvent(ActivityEventDto event) {
    final meta = event.metadata != null && event.metadata!.isNotEmpty
        ? ' (${event.metadata})'
        : '';
    switch (event.eventType) {
      case 'TaskCreated':
        return 'created a new task$meta';
      case 'TaskStatusChanged':
        return 'updated task status$meta';
      case 'TaskAssigned':
        return 'assigned a task$meta';
      case 'TaskDeleted':
        return 'deleted a task$meta';
      case 'ProjectCreated':
        return 'created project$meta';
      case 'ProjectStatusChanged':
        return 'updated project status$meta';
      case 'ProjectArchived':
        return 'archived project$meta';
      case 'MemberAdded':
        return 'joined the workspace$meta';
      case 'MemberRemoved':
        return 'left the workspace$meta';
      case 'WorkspaceCreated':
        return 'created this workspace';
      case 'WorkspaceUpdated':
        return 'updated workspace settings';
      default:
        return 'performed ${event.eventType}$meta';
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d').format(dateTime);
  }
}
