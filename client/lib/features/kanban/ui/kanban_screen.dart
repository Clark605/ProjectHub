import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/kanban/ui/widgets/create_task_sheet.dart';
import 'package:client/features/kanban/ui/widgets/kanban_app_bar.dart';
import 'package:client/features/kanban/ui/widgets/kanban_fab.dart';
import 'package:client/features/kanban/ui/widgets/kanban_view_body.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/project_status.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/ui/widgets/move_to_status_sheet.dart';
import 'package:client/features/tasks/ui/widgets/task_detail_sheet.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
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
  late final PageController _pageController;
  int _currentColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cubit =
        widget.cubit ??
        (getIt.isRegistered<KanbanCubit>()
            ? getIt<KanbanCubit>()
            : KanbanCubit(getIt(), getIt(), getIt()));
    _isInternalCubit = widget.cubit == null;
    _pageController = PageController(initialPage: 0);
    _project = widget.initialProject;
    _cubit.loadTasks(widget.projectId);
    _loadProjectAndMembers();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    if (_isInternalCubit) _cubit.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _cubit.refreshOnFocus();
  }

  Future<void> _loadProjectAndMembers() async {
    if (widget.projectId <= 0) return;
    setState(() => _isLoadingProject = true);
    try {
      if (getIt.isRegistered<ProjectRepository>()) {
        final p = await getIt<ProjectRepository>().getProject(widget.projectId);
        if (mounted) setState(() => _project = p);
        if (getIt.isRegistered<WorkspaceRepository>()) {
          final m = await getIt<WorkspaceRepository>().getMembers(
            p.workspaceId,
          );
          if (mounted) setState(() => _members = m);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoadingProject = false);
  }

  Future<void> _openSettings() async {
    final r = await Navigator.of(
      context,
    ).pushNamed(RouteNames.projectDetail, arguments: widget.projectId);
    if (!mounted) return;
    if (r == true) {
      Navigator.of(context).pop(true);
    } else {
      _loadProjectAndMembers();
      _cubit.loadTasks(widget.projectId, forceRefresh: true);
    }
  }

  void _openCreateTask([String s = 'Backlog']) => CreateTaskSheet.show(
    context,
    projectId: widget.projectId,
    initialStatus: s,
    members: _members,
    onSubmit: (req, st) =>
        _cubit.createTask(widget.projectId, req, initialStatus: st),
  );

  void _openTaskDetail(TaskDto task, bool isArchived) => TaskDetailSheet.show(
    context,
    task: task,
    isArchived: isArchived,
    members: _members,
    onUpdate: (req) => _cubit.updateTask(task.id, req),
    onStatusChange: (status) => _cubit.moveTaskStatus(task.id, status),
    onDelete: () => _cubit.deleteTask(task.id),
    onTaskUpdated: (t) => _cubit.updateTaskInLoaded(t.id, t),
  );

  void _onError(String? err) {
    if (err == null || err.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _cubit.clearErrorMessage();
  }

  @override
  Widget build(BuildContext context) {
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
            loaded: (_, _, _, _, _, _, _, e) => _onError(e),
            orElse: () {},
          );
        },
        builder: (context, state) {
          final isEffectivelyArchived =
              isArchived ||
              state.maybeWhen(
                loaded: (_, _, _, a, _, _, _, _) => a,
                empty: (_, a) => a,
                orElse: () => false,
              );
          String? wsAccent;
          try {
            wsAccent = context.watch<WorkspaceContextCubit>().state.maybeMap(
              loaded: (l) => l.activeWorkspace.accentColor,
              orElse: () => null,
            );
          } catch (_) {}

          return Scaffold(
            appBar: KanbanAppBar(
              projectName: projectName,
              wsAccent: wsAccent,
              workspaceId: _project?.workspaceId,
              onSettings: _openSettings,
            ),
            floatingActionButton: KanbanFab(
              isArchived: isEffectivelyArchived,
              onPressed: () => _openCreateTask('Backlog'),
            ),
            body: KanbanViewBody(
              state: state,
              projectId: widget.projectId,
              isArchived: isEffectivelyArchived,
              wsAccent: wsAccent,
              pageController: _pageController,
              currentColumnIndex: _currentColumnIndex,
              members: _members,
              cubit: _cubit,
              onColumnChanged: (i) => setState(() => _currentColumnIndex = i),
              onAddTask: (s) => _openCreateTask(s.toServerString()),
              onTaskTap: (t) => _openTaskDetail(t, isEffectivelyArchived),
              onTaskMove: (t) => MoveToStatusSheet.show(
                context,
                task: t,
                onStatusSelected: (s) =>
                    _cubit.moveTaskStatus(t.id, s.toServerString()),
              ),
              onTaskDelete: (t) => _cubit.deleteTask(t.id),
            ),
          );
        },
      ),
    );
  }
}
