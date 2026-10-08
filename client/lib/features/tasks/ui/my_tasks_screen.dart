import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/core/widgets/app_snackbar.dart';
import 'package:client/features/tasks/cubit/my_tasks_cubit.dart';
import 'package:client/features/tasks/cubit/my_tasks_state.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/widgets/move_to_status_sheet.dart';
import 'package:client/features/tasks/ui/widgets/my_tasks_content_slivers.dart';
import 'package:client/features/tasks/ui/widgets/my_tasks_header.dart';
import 'package:client/features/tasks/ui/widgets/task_detail_sheet.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen>
    with WidgetsBindingObserver {
  int? _activeWorkspaceId;
  List<MemberDto> _workspaceMembers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _resolveActiveWorkspace();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<MyTasksCubit>().refreshOnFocus();
    }
  }

  void _resolveActiveWorkspace() {
    try {
      context.read<WorkspaceContextCubit>().state.maybeWhen(
        loaded: (_, active) {
          _activeWorkspaceId = active.id;
          context.read<MyTasksCubit>().loadMyTasks(active.id);
          _loadWorkspaceMembers(active.id);
        },
        orElse: () {},
      );
    } catch (_) {
      // Allows running in isolated widget tests without WorkspaceContextCubit
    }
  }

  Future<void> _loadWorkspaceMembers(int workspaceId) async {
    try {
      final repo = context.read<WorkspaceRepository>();
      final members = await repo.getMembers(workspaceId);
      if (mounted) setState(() => _workspaceMembers = members);
    } catch (_) {
      // Workspace members list is non-critical for task listing; falls back gracefully
    }
  }

  void _openTaskDetail(TaskDto task) {
    final cubit = context.read<MyTasksCubit>();
    TaskDetailSheet.show(
      context,
      task: task,
      isArchived: false,
      members: _workspaceMembers,
      onUpdate: (req) => cubit.updateTask(task.id, req),
      onStatusChange: (status) => cubit.updateTaskStatus(task.id, status),
      onDelete: () => cubit.deleteTask(task.id),
    );
  }

  void _openMoveTask(TaskDto task) {
    final cubit = context.read<MyTasksCubit>();
    MoveToStatusSheet.show(
      context,
      task: task,
      onStatusSelected: (s) =>
          cubit.updateTaskStatus(task.id, s.toServerString()),
    );
  }

  void _onError(String? err) {
    if (err == null || err.isEmpty) return;
    showAppErrorSnackBar(context, err);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkspaceContextCubit, WorkspaceContextState>(
      listener: (context, wsState) {
        wsState.maybeWhen(
          loaded: (_, active) {
            if (_activeWorkspaceId != active.id) {
              _activeWorkspaceId = active.id;
              context.read<MyTasksCubit>().loadMyTasks(active.id);
              _loadWorkspaceMembers(active.id);
            }
          },
          orElse: () {},
        );
      },
      child: BlocConsumer<MyTasksCubit, MyTasksState>(
        listener: (context, state) {
          state.maybeWhen(
            loaded: (_, _, _, _, _, _, err) => _onError(err),
            orElse: () {},
          );
        },
        builder: (context, state) {
          final cubit = context.read<MyTasksCubit>();
          String? wsAccent;
          try {
            wsAccent = context.watch<WorkspaceContextCubit>().state.maybeWhen(
              loaded: (_, active) => active.accentColor,
              orElse: () => null,
            );
          } catch (_) {
            // Allows rendering screen in isolated widget tests without WorkspaceContextCubit
          }

          return AmbientGlowBackground(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (_activeWorkspaceId != null) {
                    await cubit.loadMyTasks(
                      _activeWorkspaceId!,
                      forceRefresh: true,
                    );
                  }
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: MyTasksHeader()),
                    ...MyTasksContentSlivers.build(
                      context: context,
                      state: state,
                      wsAccent: wsAccent,
                      onTaskTap: _openTaskDetail,
                      onTaskMove: _openMoveTask,
                      onToggleCollapse: cubit.toggleDoneVisibility,
                      onRetry: () {
                        if (_activeWorkspaceId != null) {
                          cubit.loadMyTasks(
                            _activeWorkspaceId!,
                            forceRefresh: true,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
