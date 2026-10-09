import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/breakpoints.dart';
import 'package:client/core/widgets/app_async_state_wrapper.dart';
import 'package:client/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:client/features/dashboard/cubit/dashboard_state.dart';
import 'package:client/features/dashboard/ui/widgets/dashboard_header.dart';
import 'package:client/features/dashboard/ui/widgets/dashboard_metrics_grid.dart';
import 'package:client/features/dashboard/ui/widgets/focus_tasks_card.dart';
import 'package:client/features/dashboard/ui/widgets/recent_activity_card.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToProjects;
  final VoidCallback? onNavigateToMyTasks;

  const DashboardScreen({
    super.key,
    this.onNavigateToProjects,
    this.onNavigateToMyTasks,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? _lastLoadedWorkspaceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final wsState = context.read<WorkspaceContextCubit>().state;
      final active = wsState.whenOrNull(loaded: (_, a) => a);
      if (active != null) {
        _lastLoadedWorkspaceId = active.id;
        context.read<DashboardCubit>().loadDashboard(active.id);
      }
    });
  }

  Future<void> _refresh(int? workspaceId) async {
    if (workspaceId != null) {
      await context.read<DashboardCubit>().loadDashboard(workspaceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkspaceContextCubit, WorkspaceContextState>(
      listener: (context, wsState) {
        wsState.mapOrNull(
          loaded: (s) {
            if (_lastLoadedWorkspaceId != s.activeWorkspace.id) {
              _lastLoadedWorkspaceId = s.activeWorkspace.id;
              context.read<DashboardCubit>().loadDashboard(
                s.activeWorkspace.id,
              );
            }
          },
        );
      },
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final wsState = context.watch<WorkspaceContextCubit>().state;
          final activeWorkspaceId = wsState.whenOrNull(loaded: (_, a) => a.id);

          return AppAsyncStateWrapper(
            onRefresh: () => _refresh(activeWorkspaceId),
            errorMessage: !state.isLoading ? state.errorMessage : null,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(),
                const SizedBox(height: 24),
                DashboardMetricsGrid(
                  activeProjects: state.activeProjects,
                  inProgressTasks: state.inProgressTasks,
                  urgentTasks: state.urgentTasks,
                  completedTasks: state.completedTasks,
                  isLoading: state.isLoading,
                  onTapActiveProjects: widget.onNavigateToProjects,
                  onTapInProgressTasks: widget.onNavigateToMyTasks,
                  onTapUrgentTasks: widget.onNavigateToMyTasks,
                  onTapCompletedTasks: widget.onNavigateToMyTasks,
                ),
                const SizedBox(height: 28),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > Breakpoints.tablet;
                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: FocusTasksCard(
                              focusTasks: state.focusTasks,
                              isLoading: state.isLoading,
                              onNavigateToMyTasks: widget.onNavigateToMyTasks,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 4,
                            child: RecentActivityCard(
                              activities: state.recentActivities,
                              isLoading: state.isLoading,
                              workspaceId: activeWorkspaceId,
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        FocusTasksCard(
                          focusTasks: state.focusTasks,
                          isLoading: state.isLoading,
                          onNavigateToMyTasks: widget.onNavigateToMyTasks,
                        ),
                        const SizedBox(height: 20),
                        RecentActivityCard(
                          activities: state.recentActivities,
                          isLoading: state.isLoading,
                          workspaceId: activeWorkspaceId,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
