import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/dashboard/ui/widgets/metric_card.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class DashboardMetricsGrid extends StatelessWidget {
  final int activeProjects;
  final int inProgressTasks;
  final int urgentBlockers;
  final int completedTasks;
  final bool isLoading;
  final VoidCallback? onTapActiveProjects;
  final VoidCallback? onTapInProgressTasks;
  final VoidCallback? onTapUrgentTasks;
  final VoidCallback? onTapCompletedTasks;

  const DashboardMetricsGrid({
    super.key,
    this.activeProjects = 0,
    this.inProgressTasks = 0,
    this.urgentBlockers = 0,
    this.completedTasks = 0,
    this.isLoading = false,
    this.onTapActiveProjects,
    this.onTapInProgressTasks,
    this.onTapUrgentTasks,
    this.onTapCompletedTasks,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 300
            ? 2
            : 1;

        final metrics = [
          (
            MetricData(
              label: l10n?.activeProjects ?? 'Active Projects',
              value: isLoading ? '...' : '$activeProjects',
              trend: 'Ongoing projects',
              icon: Icons.folder_open_rounded,
              color: AppColors.primary,
            ),
            onTapActiveProjects,
          ),
          (
            MetricData(
              label: l10n?.inProgressTasks ?? 'In Progress Tasks',
              value: isLoading ? '...' : '$inProgressTasks',
              trend: 'Assigned to you',
              icon: Icons.timelapse_rounded,
              color: AppColors.skyBlue,
            ),
            onTapInProgressTasks,
          ),
          (
            MetricData(
              label: l10n?.urgentBlockers ?? 'Urgent Tasks',
              value: isLoading ? '...' : '$urgentBlockers',
              trend: 'High priority queue',
              icon: Icons.error_outline_rounded,
              color: AppColors.priorityUrgent,
            ),
            onTapUrgentTasks,
          ),
          (
            MetricData(
              label: l10n?.completedTasks ?? 'Completed Tasks',
              value: isLoading ? '...' : '$completedTasks',
              trend: 'Finished tasks',
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.success,
            ),
            onTapCompletedTasks,
          ),
        ];

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: metrics.map((entry) {
            final cardWidth = crossAxisCount == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - (crossAxisCount - 1) * 16) /
                      crossAxisCount;

            return SizedBox(
              width: cardWidth,
              child: MetricCard(
                data: entry.$1,
                onTap: entry.$2,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
