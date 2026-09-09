import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/kanban/ui/widgets/create_task_sheet.dart';
import 'package:client/features/kanban/ui/widgets/kanban_column.dart';
import 'package:client/features/kanban/ui/widgets/kanban_empty_state.dart';
import 'package:client/features/kanban/ui/widgets/kanban_filter_bar.dart';
import 'package:client/features/kanban/ui/widgets/move_to_status_sheet.dart';
import 'package:client/features/kanban/ui/widgets/task_detail_sheet.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/project_status.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/task_status.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanScreen extends StatefulWidget {
  final int projectId;
  final ProjectDto? initialProject;
  final KanbanCubit? cubit;

  const KanbanScreen({
    super.key,
    required this.projectId,
    this.initialProject,
    this.cubit,
  });

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen>
    with WidgetsBindingObserver {
  late final KanbanCubit _cubit;
  late final bool _isInternalCubit;
  ProjectDto? _project;
  List<MemberDto> _members = [];
  bool _isLoadingProject = false;

  // Mobile column page view controller
  late final PageController _pageController;
  int _currentColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.cubit != null) {
      _cubit = widget.cubit!;
      _isInternalCubit = false;
    } else if (getIt.isRegistered<KanbanCubit>()) {
      _cubit = getIt<KanbanCubit>();
      _isInternalCubit = true;
    } else {
      // Create cubit with registered or stub repositories
      final taskRepo = getIt.isRegistered<TaskRepository>()
          ? getIt<TaskRepository>()
          : null;
      final projectRepo = getIt.isRegistered<ProjectRepository>()
          ? getIt<ProjectRepository>()
          : null;
      if (taskRepo != null && projectRepo != null) {
        _cubit = KanbanCubit(taskRepo, projectRepo);
        _isInternalCubit = true;
      } else {
        // Mock / placeholder fallback for unit tests without DI
        _cubit = KanbanCubit(_MockTaskRepository(), _MockProjectRepository());
        _isInternalCubit = true;
      }
    }

    _pageController = PageController(initialPage: 0);

    _project = widget.initialProject;
    _cubit.loadTasks(widget.projectId);

    _loadProjectAndMembers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
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

  Future<void> _loadProjectAndMembers() async {
    if (widget.projectId <= 0) return;
    setState(() => _isLoadingProject = true);

    try {
      if (getIt.isRegistered<ProjectRepository>()) {
        final projectRepo = getIt<ProjectRepository>();
        final project = await projectRepo.getProject(widget.projectId);
        if (mounted) {
          setState(() => _project = project);
        }

        if (getIt.isRegistered<WorkspaceRepository>()) {
          final wsRepo = getIt<WorkspaceRepository>();
          final members = await wsRepo.getMembers(project.workspaceId);
          if (mounted) {
            setState(() => _members = members);
          }
        }
      }
    } catch (_) {
      // Graceful fallback
    } finally {
      if (mounted) {
        setState(() => _isLoadingProject = false);
      }
    }
  }

  Future<void> _openProjectSettings() async {
    final result = await Navigator.of(
      context,
    ).pushNamed(RouteNames.projectDetail, arguments: widget.projectId);

    if (result == true && mounted) {
      Navigator.of(context).pop(true);
    } else if (mounted) {
      _loadProjectAndMembers();
      _cubit.loadTasks(widget.projectId, forceRefresh: true);
    }
  }

  void _openCreateTask([String initialStatus = 'Backlog']) {
    CreateTaskSheet.show(
      context,
      projectId: widget.projectId,
      initialStatus: initialStatus,
      members: _members,
      onSubmit: (req, targetStatus) async {
        await _cubit.createTask(
          widget.projectId,
          req,
          initialStatus: targetStatus,
        );
      },
    );
  }

  void _openTaskDetail(TaskDto task, bool isArchived) {
    TaskDetailSheet.show(
      context,
      task: task,
      isArchived: isArchived,
      members: _members,
      onUpdate: (req) => _cubit.updateTask(task.id, req),
      onStatusChange: (status) => _cubit.moveTaskStatus(task.id, status),
      onDelete: () => _cubit.deleteTask(task.id),
    );
  }

  void _openMoveTask(TaskDto task) {
    MoveToStatusSheet.show(
      context,
      task: task,
      onStatusSelected: (newStatus) {
        _cubit.moveTaskStatus(task.id, newStatus.toServerString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final projectName =
        _project?.name ??
        (_isLoadingProject ? '...' : (l10n?.projectsTitle ?? 'Project'));
    final isArchived = _project?.statusEnum == ProjectStatus.archived;

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<KanbanCubit, KanbanState>(
        listener: (context, state) {
          state.maybeWhen(
            loaded: (_, _, _, _, _, _, _, errorMessage) {
              if (errorMessage != null && errorMessage.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMessage),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                _cubit.clearErrorMessage();
              }
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          final isEffectivelyArchived =
              isArchived ||
              state.maybeWhen(
                loaded: (_, _, _, arch, _, _, _, _) => arch,
                empty: (_, arch) => arch,
                orElse: () => false,
              );

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    projectName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    l10n?.kanbanBoard ?? 'Kanban Board',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: l10n?.refreshBoard ?? 'Refresh Board',
                  onPressed: () =>
                      _cubit.loadTasks(widget.projectId, forceRefresh: true),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: l10n?.projectDetails ?? 'Project Settings',
                  onPressed: _openProjectSettings,
                ),
                const SizedBox(width: 8),
              ],
            ),
            floatingActionButton: isEffectivelyArchived
                ? null
                : FloatingActionButton.extended(
                    onPressed: () => _openCreateTask('Backlog'),
                    backgroundColor: AppColors.electricVioletContainer,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(
                      l10n?.newTask ?? 'New Task',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
            body: AmbientGlowBackground(
              child: SafeArea(
                child: Column(
                  children: [
                    // Archived persistent banner
                    if (isEffectivelyArchived)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        color: AppColors.warning.withValues(alpha: 0.15),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.archive_outlined,
                              size: 18,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n?.archivedProjectNotice ??
                                    'This project is archived. Tasks and board are read-only.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : AppColors.lightTextPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Filter Bar
                    KanbanFilterBar(
                      selectedPriority: _cubit.priorityFilter,
                      selectedAssignee: _cubit.assigneeFilter,
                      searchQuery: _cubit.searchFilter,
                      members: _members,
                      onPrioritySelected: (priority) =>
                          _cubit.setFilter(priority: priority),
                      onAssigneeSelected: (assigneeId) =>
                          _cubit.setFilter(assigneeId: assigneeId),
                      onSearchChanged: (query) =>
                          _cubit.setFilter(search: query),
                      onClearFilters: () => _cubit.clearFilters(),
                    ),

                    // Main Board Area
                    Expanded(
                      child: RefreshIndicator(
                        notificationPredicate: (notification) =>
                            notification.metrics.axis == Axis.vertical,
                        onRefresh: () => _cubit.loadTasks(
                          widget.projectId,
                          forceRefresh: true,
                        ),
                        child: _buildBoardBody(
                          context,
                          state,
                          isEffectivelyArchived,
                        ),
                      ),
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

  Widget _buildBoardBody(
    BuildContext context,
    KanbanState state,
    bool isArchived,
  ) {
    final l10n = AppLocalizations.of(context);
    return state.when(
      initial: () => const Center(child: CircularProgressIndicator()),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (message) => Center(
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
                onPressed: () =>
                    _cubit.loadTasks(widget.projectId, forceRefresh: true),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
              ),
            ],
          ),
        ),
      ),
      empty: (_, arch) => KanbanEmptyState(
        isArchived: arch,
        onCreateTask: () => _openCreateTask('Backlog'),
      ),
      loaded:
          (projectId, tasks, allTasks, arch, search, priority, assignee, err) {
            if (tasks.isEmpty &&
                (search != null || priority != null || assignee != null)) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.filter_list_off_rounded,
                        size: 44,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n?.noTasksMatchFilters ??
                            'No tasks match active filters',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () => _cubit.clearFilters(),
                        child: Text(l10n?.clearFilters ?? 'Clear Filters'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final tasksByStatus = state.tasksByStatus;

            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 768;

                if (isMobile) {
                  return _buildMobileBoard(context, tasksByStatus, arch);
                } else {
                  return _buildDesktopBoard(
                    context,
                    tasksByStatus,
                    arch,
                    constraints.maxHeight,
                  );
                }
              },
            );
          },
    );
  }

  Widget _buildMobileBoard(
    BuildContext context,
    Map<TaskStatus, List<TaskDto>> tasksByStatus,
    bool isArchived,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Column segmented tab selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: TaskStatus.values.asMap().entries.map((entry) {
                final idx = entry.key;
                final status = entry.value;
                final isSelected = idx == _currentColumnIndex;
                final count = tasksByStatus[status]?.length ?? 0;
                final statusName = l10n != null
                    ? status.localizedName(l10n)
                    : status.toDisplayString();

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    showCheckmark: false,
                    avatar: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: status.toColor(),
                        shape: BoxShape.circle,
                      ),
                    ),
                    label: Text('$statusName ($count)'),
                    labelStyle: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary),
                      fontSize: 12,
                    ),
                    onSelected: (_) {
                      setState(() => _currentColumnIndex = idx);
                      _pageController.animateToPage(
                        idx,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Swipeable PageView of Kanban Columns
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: TaskStatus.values.length,
            onPageChanged: (index) {
              setState(() => _currentColumnIndex = index);
            },
            itemBuilder: (context, index) {
              final status = TaskStatus.values[index];
              final columnTasks = tasksByStatus[status] ?? [];

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: KanbanColumn(
                  status: status,
                  tasks: columnTasks,
                  isArchived: isArchived,
                  onAddTask: () => _openCreateTask(status.toServerString()),
                  onTaskTap: (task) => _openTaskDetail(task, isArchived),
                  onTaskMove: _openMoveTask,
                  onTaskDelete: (task) => _cubit.deleteTask(task.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBoard(
    BuildContext context,
    Map<TaskStatus, List<TaskDto>> tasksByStatus,
    bool isArchived,
    double availableHeight,
  ) {
    final columnHeight = (availableHeight - 32).clamp(300.0, double.infinity);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: TaskStatus.values.map((status) {
          final columnTasks = tasksByStatus[status] ?? [];
          return SizedBox(
            width: 300,
            height: columnHeight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: KanbanColumn(
                status: status,
                tasks: columnTasks,
                isArchived: isArchived,
                onAddTask: () => _openCreateTask(status.toServerString()),
                onTaskTap: (task) => _openTaskDetail(task, isArchived),
                onTaskMove: _openMoveTask,
                onTaskDelete: (task) => _cubit.deleteTask(task.id),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MockTaskRepository implements TaskRepository {
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

class _MockProjectRepository implements ProjectRepository {
  @override
  void clearCache([int? wsId]) {}
  @override
  Future<List<ProjectDto>> getProjects(
    int wsId, {
    String? status,
    bool forceRefresh = false,
  }) async => [];
  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async =>
      throw UnimplementedError();
  @override
  Future<ProjectDto> createProject(int wsId, CreateProjectRequest req) async =>
      throw UnimplementedError();
  @override
  Future<ProjectDto> updateProject(int id, UpdateProjectRequest req) async =>
      throw UnimplementedError();
  @override
  Future<void> deleteProject(int id) async {}
  @override
  bool hasCachedProjects(int wsId) => false;
  @override
  bool hasCachedProject(int id) => false;
}
