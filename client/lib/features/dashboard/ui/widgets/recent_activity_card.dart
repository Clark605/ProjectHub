import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key});

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
            ],
          ),
          const SizedBox(height: 16),
          const _ActivityTile(
            user: 'Alex K.',
            avatarText: 'AK',
            avatarColor: AppColors.electricViolet,
            action: 'moved task',
            target: 'Setup Auth Interceptor',
            status: 'Done',
            time: '5m ago',
          ),
          const Divider(color: AppColors.border, height: 16),
          const _ActivityTile(
            user: 'Sarah M.',
            avatarText: 'SM',
            avatarColor: AppColors.skyBlue,
            action: 'created project',
            target: 'Mobile Client v1',
            status: 'Active',
            time: '32m ago',
          ),
          const Divider(color: AppColors.border, height: 16),
          const _ActivityTile(
            user: 'David R.',
            avatarText: 'DR',
            avatarColor: AppColors.warning,
            action: 'assigned you to',
            target: 'Audit Postgres Migration',
            status: 'InProgress',
            time: '2h ago',
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String user;
  final String avatarText;
  final Color avatarColor;
  final String action;
  final String target;
  final String status;
  final String time;

  const _ActivityTile({
    required this.user,
    required this.avatarText,
    required this.avatarColor,
    required this.action,
    required this.target,
    required this.status,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  text: '$user ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(
                  text: '$action ',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                TextSpan(
                  text: target,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.electricViolet,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          time,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
