import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:client/features/dashboard/cubit/dashboard_state.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/ui/widgets/dashboard_header.dart';
import 'package:client/features/dashboard/ui/widgets/dashboard_metrics_grid.dart';
import 'package:client/features/dashboard/ui/widgets/recent_activity_card.dart';
import 'package:client/features/dashboard/ui/widgets/sprint_focus_card.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';

class _FallbackActivityRepository implements ActivityRepository {
  @override
  Future<List<ActivityEventDto>> getWorkspaceActivities(
    int workspaceId, {
    int limit = 20,
  }) async => [];

  @override
  Future<List<ActivityEventDto>> getProjectActivities(
    int projectId, {
    int limit = 20,
  }) async => [];
}

class _FallbackProjectRepository implements ProjectRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FallbackTaskRepository implements TaskRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class DashboardScreen extends StatefulWidget {
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
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardCubit _cubit;
  late final bool _isInternalCubit;
  int? _activeWorkspaceId;

  @override
  void initState() {
    super.initState();
    if (widget.cubit != null) {
      _cubit = widget.cubit!;
      _isInternalCubit = false;
    } else if (getIt.isRegistered<DashboardCubit>()) {
      _cubit = getIt<DashboardCubit>();
      _isInternalCubit = false;
    } else {
      final actRepo = getIt.isRegistered<ActivityRepository>()
          ? getIt<ActivityRepository>()
          : _FallbackActivityRepository();
      final projRepo = getIt.isRegistered<ProjectRepository>()
          ? getIt<ProjectRepository>()
          : _FallbackProjectRepository();
      final taskRepo = getIt.isRegistered<TaskRepository>()
          ? getIt<TaskRepository>()
          : _FallbackTaskRepository();
      _cubit = DashboardCubit(actRepo, projRepo, taskRepo);
      _isInternalCubit = true;
    }

    if (getIt.isRegistered<WorkspaceContextCubit>()) {
      final wsCubit = getIt<WorkspaceContextCubit>();
      wsCubit.state.mapOrNull(
        loaded: (s) {
          _activeWorkspaceId = s.activeWorkspace.id;
          _cubit.loadDashboard(s.activeWorkspace.id);
        },
      );
    }
  }

  @override
  void dispose() {
    if (_isInternalCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wsCubit = getIt.isRegistered<WorkspaceContextCubit>()
        ? getIt<WorkspaceContextCubit>()
        : null;

    final child = BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              if (_activeWorkspaceId != null) {
                await _cubit.loadDashboard(_activeWorkspaceId!);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
      ),
    );

    if (wsCubit != null) {
      return BlocListener<WorkspaceContextCubit, WorkspaceContextState>(
        bloc: wsCubit,
        listener: (context, wsState) {
          wsState.mapOrNull(
            loaded: (s) {
              if (_activeWorkspaceId != s.activeWorkspace.id) {
                _activeWorkspaceId = s.activeWorkspace.id;
                _cubit.loadDashboard(s.activeWorkspace.id);
              }
            },
          );
        },
        child: child,
      );
    }

    return child;
  }
}
