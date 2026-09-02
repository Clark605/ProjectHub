import 'package:flutter/material.dart';

import 'package:client/features/dashboard/ui/widgets/dashboard_header.dart';
import 'package:client/features/dashboard/ui/widgets/dashboard_metrics_grid.dart';
import 'package:client/features/dashboard/ui/widgets/recent_activity_card.dart';
import 'package:client/features/dashboard/ui/widgets/sprint_focus_card.dart';

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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome & Velocity Header ──
          const DashboardHeader(),
          const SizedBox(height: 24),

          // ── Key Metrics Grid ──
          const DashboardMetricsGrid(),
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
                      child: SprintFocusCard(
                        onNavigateToMyTasks: onNavigateToMyTasks,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      flex: 4,
                      child: RecentActivityCard(),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  SprintFocusCard(
                    onNavigateToMyTasks: onNavigateToMyTasks,
                  ),
                  const SizedBox(height: 20),
                  const RecentActivityCard(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
