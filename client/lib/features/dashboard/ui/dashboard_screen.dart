import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';
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
import 'package:client/features/workspaces/ui/widgets/active_workspace_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onNavigateToProjects;
  final VoidCallback? onNavigateToMyTasks;

  const DashboardScreen({
    super.key,
    this.onNavigateToProjects,
    this.onNavigateToMyTasks,
  });

  Future<void> _refresh(BuildContext context, int? workspaceId) async {
    if (workspaceId != null) {
      await context.read<DashboardCubit>().loadDashboard(workspaceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActiveWorkspaceListener(
      onWorkspaceChanged: (context, activeId) {
        if (activeId != null) {
          context.read<DashboardCubit>().loadDashboard(activeId);
        }
      },
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          final activeWorkspaceId =
              context.watch<WorkspaceContextCubit>().state.activeWorkspaceId;

          return AppAsyncStateWrapper(
            onRefresh: () => _refresh(context, activeWorkspaceId),
            errorMessage: !state.isLoading
                ? state.failure?.localized(context)
                : null,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(),
                AppSpacing.gapHXxl,
                DashboardMetricsGrid(
                  activeProjects: state.activeProjects,
                  inProgressTasks: state.inProgressTasks,
                  urgentTasks: state.urgentTasks,
                  completedTasks: state.completedTasks,
                  isLoading: state.isLoading,
                  onTapActiveProjects: onNavigateToProjects,
                  onTapInProgressTasks: onNavigateToMyTasks,
                  onTapUrgentTasks: onNavigateToMyTasks,
                  onTapCompletedTasks: onNavigateToMyTasks,
                ),
                AppSpacing.gapHXxl,
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
                              onNavigateToMyTasks: onNavigateToMyTasks,
                            ),
                          ),
                          AppSpacing.gapWXl,
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
                          onNavigateToMyTasks: onNavigateToMyTasks,
                        ),
                        AppSpacing.gapHXl,
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
