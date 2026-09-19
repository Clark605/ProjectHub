import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/tasks/cubit/my_tasks_cubit.dart';
import 'package:client/features/tasks/cubit/my_tasks_state.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/tasks/ui/widgets/move_to_status_sheet.dart';
import 'package:client/features/tasks/ui/widgets/my_tasks_content_slivers.dart';
import 'package:client/features/tasks/ui/widgets/my_tasks_header.dart';
import 'package:client/features/tasks/ui/widgets/task_detail_sheet.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

class MyTasksScreen extends StatefulWidget {
  final MyTasksCubit? cubit;

  const MyTasksScreen({super.key, this.cubit});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen>
    with WidgetsBindingObserver {
  late final MyTasksCubit _cubit;
  late final bool _isInternalCubit;
  int? _activeWorkspaceId;
  List<MemberDto> _workspaceMembers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.cubit != null) {
      _cubit = widget.cubit!;
      _isInternalCubit = false;
    } else {
      _cubit = getIt.isRegistered<MyTasksCubit>()
          ? getIt<MyTasksCubit>()
          : MyTasksCubit(getIt<TaskRepository>());
      _isInternalCubit = true;
    }
    _resolveActiveWorkspace();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isInternalCubit) _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _cubit.refreshOnFocus();
  }

  void _resolveActiveWorkspace() {
    if (getIt.isRegistered<WorkspaceContextCubit>()) {
      getIt<WorkspaceContextCubit>().state.maybeWhen(
        loaded: (_, active) {
          _activeWorkspaceId = active.id;
          _cubit.loadMyTasks(active.id);
          _loadWorkspaceMembers(active.id);
        },
        orElse: () {},
      );
    }
  }

  Future<void> _loadWorkspaceMembers(int workspaceId) async {
    if (getIt.isRegistered<WorkspaceRepository>()) {
      try {
        final members = await getIt<WorkspaceRepository>().getMembers(workspaceId);
        if (mounted) setState(() => _workspaceMembers = members);
      } catch (_) {}
    }
  }

  void _openTaskDetail(TaskDto task) {
    TaskDetailSheet.show(
      context,
      task: task,
      isArchived: false,
      members: _workspaceMembers,
      onUpdate: (req) => _cubit.updateTask(task.id, req),
      onStatusChange: (status) => _cubit.updateTaskStatus(task.id, status),
      onDelete: () => _cubit.deleteTask(task.id),
    );
  }

  void _openMoveTask(TaskDto task) {
    MoveToStatusSheet.show(
      context,
      task: task,
      onStatusSelected: (s) =>
          _cubit.updateTaskStatus(task.id, s.toServerString()),
    );
  }

  void _onError(String? err) {
    if (err == null || err.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wsCubit = getIt.isRegistered<WorkspaceContextCubit>()
        ? getIt<WorkspaceContextCubit>()
        : null;

    final content = BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<MyTasksCubit, MyTasksState>(
        listener: (context, state) {
          state.maybeWhen(
            loaded: (_, _, _, _, _, _, err) => _onError(err),
            orElse: () {},
          );
        },
        builder: (context, state) {
          String? wsAccent;
          try {
            wsAccent = context.watch<WorkspaceContextCubit>().state.maybeWhen(
                  loaded: (_, active) => active.accentColor,
                  orElse: () => null,
                );
          } catch (_) {
            wsAccent = wsCubit?.state.maybeWhen(
              loaded: (_, active) => active.accentColor,
              orElse: () => null,
            );
          }

          return AmbientGlowBackground(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (_activeWorkspaceId != null) {
                    await _cubit.loadMyTasks(_activeWorkspaceId!, forceRefresh: true);
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
                      onToggleCollapse: _cubit.toggleDoneVisibility,
                      onRetry: () {
                        if (_activeWorkspaceId != null) {
                          _cubit.loadMyTasks(_activeWorkspaceId!, forceRefresh: true);
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

    if (wsCubit != null) {
      return BlocListener<WorkspaceContextCubit, WorkspaceContextState>(
        bloc: wsCubit,
        listener: (context, wsState) {
          wsState.maybeWhen(
            loaded: (_, active) {
              if (_activeWorkspaceId != active.id) {
                _activeWorkspaceId = active.id;
                _cubit.loadMyTasks(active.id);
                _loadWorkspaceMembers(active.id);
              }
            },
            orElse: () {},
          );
        },
        child: content,
      );
    }

    return content;
  }
}
