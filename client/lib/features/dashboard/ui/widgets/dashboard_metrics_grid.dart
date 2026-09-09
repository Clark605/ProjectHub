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

  const DashboardMetricsGrid({
    super.key,
    this.activeProjects = 0,
    this.inProgressTasks = 0,
    this.urgentBlockers = 0,
    this.completedTasks = 0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 650
            ? 2
            : 1;

        final metrics = [
          MetricData(
            label: l10n?.activeProjects ?? 'Active Projects',
            value: isLoading ? '...' : '$activeProjects',
            trend: 'In current workspace',
            icon: Icons.folder_special_rounded,
            color: AppColors.electricViolet,
          ),
          MetricData(
            label: l10n?.inProgressTasks ?? 'In Progress Tasks',
            value: isLoading ? '...' : '$inProgressTasks',
            trend: 'Assigned to you',
            icon: Icons.timelapse_rounded,
            color: AppColors.skyBlue,
          ),
          MetricData(
            label: l10n?.urgentBlockers ?? 'Urgent Blockers',
            value: isLoading ? '...' : '$urgentBlockers',
            trend: 'High priority queue',
            icon: Icons.error_outline_rounded,
            color: AppColors.priorityUrgent,
          ),
          MetricData(
            label: l10n?.completedTasks ?? 'Completed Tasks',
            value: isLoading ? '...' : '$completedTasks',
            trend: 'Finished tasks',
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
              child: MetricCard(data: m),
            );
          }).toList(),
        );
      },
    );
  }
}
