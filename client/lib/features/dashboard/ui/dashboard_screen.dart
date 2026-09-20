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
  final DashboardCubit? cubit;

  const DashboardScreen({
    super.key,
    this.onNavigateToProjects,
    this.onNavigateToMyTasks,
    this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    DashboardCubit? effectiveCubit = cubit;
    if (effectiveCubit == null) {
      try {
        effectiveCubit = context.read<DashboardCubit>();
      } catch (_) {
        if (getIt.isRegistered<DashboardCubit>()) {
          effectiveCubit = getIt<DashboardCubit>();
        }
      }
    }

    Widget content = _DashboardView(
      onNavigateToProjects: onNavigateToProjects,
      onNavigateToMyTasks: onNavigateToMyTasks,
    );

    if (effectiveCubit != null) {
      content = BlocProvider.value(value: effectiveCubit, child: content);
    }

    return content;
  }
}

class _DashboardView extends StatefulWidget {
  final VoidCallback? onNavigateToProjects;
  final VoidCallback? onNavigateToMyTasks;

  const _DashboardView({this.onNavigateToProjects, this.onNavigateToMyTasks});

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  int? _activeWorkspaceId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        final wsCubit = context.read<WorkspaceContextCubit>();
        final active = wsCubit.state.whenOrNull(loaded: (_, a) => a);
        if (active != null) {
          _activeWorkspaceId = active.id;
          context.read<DashboardCubit>().loadDashboard(active.id);
        }
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    WorkspaceContextCubit? wsCubit;
    try {
      wsCubit = context.read<WorkspaceContextCubit>();
    } catch (_) {
      if (getIt.isRegistered<WorkspaceContextCubit>()) {
        wsCubit = getIt<WorkspaceContextCubit>();
      }
    }

    Widget view = BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            if (_activeWorkspaceId != null) {
              await context.read<DashboardCubit>().loadDashboard(
                _activeWorkspaceId!,
              );
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const DashboardHeader(),
                const SizedBox(height: 24),
                DashboardMetricsGrid(
                  activeProjects: state.activeProjects,
                  inProgressTasks: state.inProgressTasks,
                  urgentBlockers: state.urgentBlockers,
                  completedTasks: state.completedTasks,
                  isLoading: state.isLoading,
                ),
                const SizedBox(height: 28),
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
                              onNavigateToMyTasks: widget.onNavigateToMyTasks,
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
                          onNavigateToMyTasks: widget.onNavigateToMyTasks,
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
    );

    if (wsCubit != null) {
      view = BlocListener<WorkspaceContextCubit, WorkspaceContextState>(
        bloc: wsCubit,
        listener: (context, wsState) {
          wsState.mapOrNull(
            loaded: (s) {
              if (_activeWorkspaceId != s.activeWorkspace.id) {
                _activeWorkspaceId = s.activeWorkspace.id;
                context.read<DashboardCubit>().loadDashboard(
                  s.activeWorkspace.id,
                );
              }
            },
          );
        },
        child: view,
      );
    }

    return view;
  }
}
