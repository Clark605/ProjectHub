import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:client/features/dashboard/cubit/dashboard_state.dart';
import 'package:client/features/dashboard/ui/widgets/dashboard_header.dart';
import 'package:client/features/dashboard/ui/widgets/dashboard_metrics_grid.dart';
import 'package:client/features/dashboard/ui/widgets/recent_activity_card.dart';
import 'package:client/features/dashboard/ui/widgets/sprint_focus_card.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';

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
    return BlocProvider(
      create: (context) {
        final cubit = getIt<DashboardCubit>();
        final workspaceState = context.read<WorkspaceContextCubit>().state;
        workspaceState.mapOrNull(
          loaded: (s) => cubit.loadDashboard(s.activeWorkspace.id),
        );
        return cubit;
      },
      child: BlocListener<WorkspaceContextCubit, WorkspaceContextState>(
        listener: (context, state) {
          state.mapOrNull(
            loaded: (s) =>
                context.read<DashboardCubit>().loadDashboard(s.activeWorkspace.id),
          );
        },
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                final wsState = context.read<WorkspaceContextCubit>().state;
                await wsState.mapOrNull(
                  loaded: (s) =>
                      context.read<DashboardCubit>().loadDashboard(s.activeWorkspace.id),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Welcome & Velocity Header ──
                    const DashboardHeader(),
                    const SizedBox(height: 24),

                    // ── Key Metrics Grid ──
                    DashboardMetricsGrid(
                      activeProjects: state.activeProjects,
                      inProgressTasks: state.inProgressTasks,
                      urgentBlockers: state.urgentBlockers,
                      completedTasks: state.completedTasks,
                      isLoading: state.isLoading,
                    ),
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
                                  focusTasks: state.focusTasks,
                                  isLoading: state.isLoading,
                                  onNavigateToMyTasks: onNavigateToMyTasks,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 4,
                                child: RecentActivityCard(
                                  activities: state.recentActivities,
                                  isLoading: state.isLoading,
                                ),
                              ),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            SprintFocusCard(
                              focusTasks: state.focusTasks,
                              isLoading: state.isLoading,
                              onNavigateToMyTasks: onNavigateToMyTasks,
                            ),
                            const SizedBox(height: 20),
                            RecentActivityCard(
                              activities: state.recentActivities,
                              isLoading: state.isLoading,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
