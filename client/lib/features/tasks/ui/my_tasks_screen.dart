import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/kanban/ui/widgets/move_to_status_sheet.dart';
import 'package:client/features/kanban/ui/widgets/task_detail_sheet.dart';
import 'package:client/features/tasks/cubit/my_tasks_cubit.dart';
import 'package:client/features/tasks/cubit/my_tasks_state.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/tasks/ui/widgets/my_tasks_section.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
    } else if (getIt.isRegistered<MyTasksCubit>()) {
      _cubit = getIt<MyTasksCubit>();
      _isInternalCubit = true;
    } else {
      final repo = getIt.isRegistered<TaskRepository>()
          ? getIt<TaskRepository>()
          : _FallbackMyTasksRepository();
      _cubit = MyTasksCubit(repo);
      _isInternalCubit = true;
    }

    _resolveActiveWorkspace();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_isInternalCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cubit.refreshOnFocus();
    }
  }

  void _resolveActiveWorkspace() {
    if (getIt.isRegistered<WorkspaceContextCubit>()) {
      final wsCubit = getIt<WorkspaceContextCubit>();
      wsCubit.state.maybeWhen(
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
        final repo = getIt<WorkspaceRepository>();
        final members = await repo.getMembers(workspaceId);
        if (mounted) {
          setState(() => _workspaceMembers = members);
        }
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
      onStatusSelected: (newStatus) {
        _cubit.updateTaskStatus(task.id, newStatus.toServerString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final wsCubit = getIt.isRegistered<WorkspaceContextCubit>()
        ? getIt<WorkspaceContextCubit>()
        : null;

    final content = BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<MyTasksCubit, MyTasksState>(
        listener: (context, state) {
          state.maybeWhen(
            loaded: (_, _, _, _, _, _, errorMessage) {
              if (errorMessage != null && errorMessage.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return AmbientGlowBackground(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (_activeWorkspaceId != null) {
                    await _cubit.loadMyTasks(
                      _activeWorkspaceId!,
                      forceRefresh: true,
                    );
                  }
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    // Header Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.myTasksTitle ?? 'My Tasks',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n?.myTasksSubtitle ??
                                  'Personal sprint backlog and assigned deliverables.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.textSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // State-dependent content
                    ..._buildContentSlivers(context, state),
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

  List<Widget> _buildContentSlivers(BuildContext context, MyTasksState state) {
    final l10n = AppLocalizations.of(context);

    return state.when(
      initial: () => [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      loading: () => [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (message) => [
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_activeWorkspaceId != null) {
                        _cubit.loadMyTasks(
                          _activeWorkspaceId!,
                          forceRefresh: true,
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n?.retry ?? 'Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      empty: (wsId) => [SliverFillRemaining(child: _buildEmptyView(context))],
      loaded: (wsId, urgent, inProgress, todo, done, showDone, _) {
        final hasAnyTasks =
            urgent.isNotEmpty ||
            inProgress.isNotEmpty ||
            todo.isNotEmpty ||
            done.isNotEmpty;

        if (!hasAnyTasks) {
          return [SliverFillRemaining(child: _buildEmptyView(context))];
        }

        return [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Overdue / Urgent
                if (urgent.isNotEmpty)
                  MyTasksSection(
                    emoji: '🚨',
                    title: l10n?.overdueUrgent ?? 'Overdue & Urgent',
                    tasks: urgent,
                    onTaskTap: _openTaskDetail,
                    onTaskStatusTap: _openMoveTask,
                  ),

                // In Progress
                if (inProgress.isNotEmpty)
                  MyTasksSection(
                    emoji: '⚡',
                    title: l10n?.inProgress ?? 'In Progress',
                    tasks: inProgress,
                    onTaskTap: _openTaskDetail,
                    onTaskStatusTap: _openMoveTask,
                  ),

                // Up Next
                if (todo.isNotEmpty)
                  MyTasksSection(
                    emoji: '📋',
                    title: l10n?.upNext ?? 'Up Next',
                    tasks: todo,
                    onTaskTap: _openTaskDetail,
                    onTaskStatusTap: _openMoveTask,
                  ),

                // Recently Done (Collapsible)
                MyTasksSection(
                  emoji: '✅',
                  title: l10n?.recentlyDone ?? 'Recently Done',
                  tasks: done,
                  isCollapsible: true,
                  isCollapsed: !showDone,
                  onToggleCollapse: () => _cubit.toggleDoneVisibility(),
                  onTaskTap: _openTaskDetail,
                  onTaskStatusTap: _openMoveTask,
                ),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ];
      },
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: (isDark
                  ? theme.colorScheme.surfaceContainerLow
                  : theme.colorScheme.surface)
              .withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.skyBlue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.skyBlue.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: AppColors.skyBlue,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n?.noAssignedTasks ?? 'No Assigned Tasks',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.noAssignedTasksSubtitle ??
                  'You have no pending tasks assigned in this workspace. Take a break or check project boards!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackMyTasksRepository implements TaskRepository {
  @override
  void clearCache([int? projectId]) {}
  @override
  Future<List<TaskDto>> getTasksByProject(
    int projectId, {
    String? status,
    String? assigneeId,
    String? priority,
    bool forceRefresh = false,
  }) async => [];
  @override
  Future<List<TaskDto>> getMyTasks(
    int workspaceId, {
    bool forceRefresh = false,
  }) async => [];
  @override
  Future<TaskDto> getTask(int taskId, {bool forceRefresh = false}) async =>
      throw UnimplementedError();
  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async =>
      throw UnimplementedError();
  @override
  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request) async =>
      throw UnimplementedError();
  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async =>
      throw UnimplementedError();
  @override
  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId) async =>
      throw UnimplementedError();
  @override
  Future<void> deleteTask(int taskId) async {}
  @override
  bool hasCachedTasks(int projectId) => false;
}
