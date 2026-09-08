import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/dashboard/ui/widgets/metric_card.dart';

class DashboardMetricsGrid extends StatelessWidget {
  const DashboardMetricsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1100
            ? 4
            : constraints.maxWidth > 650
            ? 2
            : 1;

        final metrics = [
          const MetricData(
            label: 'Active Projects',
            value: '4',
            trend: '2 in sprint',
            icon: Icons.folder_special_rounded,
            color: AppColors.electricViolet,
          ),
          const MetricData(
            label: 'In Progress Tasks',
            value: '12',
            trend: '4 assigned to you',
            icon: Icons.timelapse_rounded,
            color: AppColors.skyBlue,
          ),
          const MetricData(
            label: 'Urgent Blockers',
            value: '2',
            trend: 'Needs review today',
            icon: Icons.error_outline_rounded,
            color: AppColors.priorityUrgent,
          ),
          const MetricData(
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
              child: MetricCard(data: m),
            );
          }).toList(),
        );
      },
    );
  }
}
