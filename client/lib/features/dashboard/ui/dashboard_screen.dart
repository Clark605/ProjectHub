import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:client/core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToProjects;
  final VoidCallback? onNavigateToMyTasks;

  const DashboardScreen({
    super.key,
    this.onNavigateToProjects,
    this.onNavigateToMyTasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome & Velocity Header ──
          _buildHeader(context, theme),
          const SizedBox(height: 24),

          // ── Key Metrics Grid ──
          _buildMetricsGrid(context, theme),
          const SizedBox(height: 28),

          // ── Two Column Focus & Recent Activity ──
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildSprintFocusCard(context, theme),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 4,
                      child: _buildRecentActivityCard(context, theme),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  _buildSprintFocusCard(context, theme),
                  const SizedBox(height: 20),
                  _buildRecentActivityCard(context, theme),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sprint Overview',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Track team velocity, active sprint deliverables, and daily focus items.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Sprint Velocity Floating Pill (+42% Velocity)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0284C7), AppColors.success],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                    duration: 1000.ms,
                  ),
              const SizedBox(width: 8),
              const Text(
                '+42% Velocity',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(BuildContext context, ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 650
                ? 2
                : 1;

        final metrics = [
          _MetricData(
            label: 'Active Projects',
            value: '4',
            trend: '2 in sprint',
            icon: Icons.folder_special_rounded,
            color: AppColors.electricViolet,
          ),
          _MetricData(
            label: 'In Progress Tasks',
            value: '12',
            trend: '4 assigned to you',
            icon: Icons.timelapse_rounded,
            color: AppColors.skyBlue,
          ),
          _MetricData(
            label: 'Urgent Blockers',
            value: '2',
            trend: 'Needs review today',
            icon: Icons.error_outline_rounded,
            color: AppColors.priorityUrgent,
          ),
          _MetricData(
            label: 'Completed Tasks',
            value: '28',
            trend: '+8 this week',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: metrics.map((m) {
            final cardWidth = crossAxisCount == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                    crossAxisCount;

            return SizedBox(
              width: cardWidth,
              child: _MetricCard(data: m),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildSprintFocusCard(BuildContext context, ThemeData theme) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'My Active Focus',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (onNavigateToMyTasks != null)
                TextButton(
                  onPressed: onNavigateToMyTasks,
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const _FocusTaskTile(
            title: 'Implement Refresh Token Queue Interceptor',
            project: 'Mobile Client v1',
            priority: 'Urgent',
            priorityColor: AppColors.priorityUrgent,
            dueDate: 'Today',
          ),
          const SizedBox(height: 10),
          const _FocusTaskTile(
            title: 'Design 5-Column Responsive Kanban Matrix',
            project: 'Design Systems',
            priority: 'High',
            priorityColor: AppColors.priorityHigh,
            dueDate: 'Tomorrow',
          ),
          const SizedBox(height: 10),
          const _FocusTaskTile(
            title: 'Audit Postgres Migration Rollbacks',
            project: 'Backend API 10',
            priority: 'Medium',
            priorityColor: AppColors.priorityMedium,
            dueDate: 'Sep 05',
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(BuildContext context, ThemeData theme) {
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

class _MetricData {
  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color color;

  _MetricData({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.color,
  });
}

class _MetricCard extends StatelessWidget {
  final _MetricData data;

  const _MetricCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  data.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(data.icon, color: data.color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.trend,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusTaskTile extends StatelessWidget {
  final String title;
  final String project;
  final String priority;
  final Color priorityColor;
  final String dueDate;

  const _FocusTaskTile({
    required this.title,
    required this.project,
    required this.priority,
    required this.priorityColor,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: priorityColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  project,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              priority,
              style: TextStyle(
                color: priorityColor,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
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
