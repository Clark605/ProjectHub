import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/cubit/kanban_state.dart';
import 'package:client/features/kanban/ui/widgets/kanban_app_bar.dart';
import 'package:client/features/kanban/ui/widgets/kanban_screen_actions.dart';
import 'package:client/features/kanban/ui/widgets/kanban_screen_fab.dart';
import 'package:client/features/kanban/ui/widgets/kanban_view_body.dart';
import 'package:client/features/kanban/ui/widgets/kanban_voice_handler.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/project_status.dart';
import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanScreen extends StatefulWidget {
  final int projectId;
  final ProjectDto? initialProject;
  final KanbanCubit? cubit;
  final VoiceTaskCubit? voiceCubit;

  const KanbanScreen({
    super.key,
    required this.projectId,
    this.initialProject,
    this.cubit,
    this.voiceCubit,
  });

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen>
    with WidgetsBindingObserver {
  late KanbanCubit _cubit;
  ProjectDto? _project;
  List<MemberDto> _members = [];
  bool _isLoadingProject = false;
  bool _didInit = false;
  late final PageController _pageController;
  int _currentColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pageController = PageController(initialPage: 0);
    _project = widget.initialProject;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      _cubit = widget.cubit ?? context.read<KanbanCubit>();
      _cubit.loadTasks(widget.projectId);
      _loadProjectAndMembers();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _cubit.refreshOnFocus();
  }

  Future<void> _loadProjectAndMembers() async {
    setState(() => _isLoadingProject = true);
    final res = await KanbanScreenActions.loadProjectAndMembers(widget.projectId);
    if (mounted) {
      setState(() {
        if (res != null) {
          _project = res.$1;
          _members = res.$2;
        }
        _isLoadingProject = false;
      });
    }
  }

  Future<void> _handleSettings() async {
    final updated = await KanbanScreenActions.openSettings(context, widget.projectId);
    if (updated != null && mounted) setState(() => _project = updated);
  }

  void _openCreateTask([String status = 'Backlog']) {
    KanbanScreenActions.openCreateTask(
      context,
      projectId: widget.projectId,
      members: _members,
      cubit: _cubit,
      status: status,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final projectName =
        _project?.name ??
        (_isLoadingProject ? '...' : (l10n?.projectsTitle ?? 'Project'));
    final isArchived = _project?.statusEnum == ProjectStatus.archived;
    final voiceCubit = KanbanScreenActions.getVoiceCubit(context, widget.voiceCubit);

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<KanbanCubit, KanbanState>(
      bloc: widget.cubit != null ? _cubit : null,
      listener: (context, state) {
        state.maybeWhen(
          loaded: (_, _, _, _, _, _, _, e) =>
              KanbanScreenActions.showError(context, e, _cubit),
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
        final wsAccent = KanbanScreenActions.getWorkspaceAccent(context);

        Widget bodyContent = KanbanViewBody(
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
          onTaskTap: (t) => KanbanScreenActions.openTaskDetail(
            context,
            task: t,
            isArchived: isEffectivelyArchived,
            members: _members,
            cubit: _cubit,
          ),
          onTaskMove: (t) => KanbanScreenActions.openMoveToStatus(
            context,
            task: t,
            cubit: _cubit,
          ),
          onTaskDelete: (t) => _cubit.deleteTask(t.id),
        );

        if (voiceCubit != null) {
          bodyContent = KanbanVoiceHandler(
            projectId: widget.projectId,
            workspaceId: _project?.workspaceId ?? 0,
            members: _members,
            kanbanCubit: _cubit,
            child: bodyContent,
          );
        }

        return Scaffold(
          appBar: KanbanAppBar(
            projectName: projectName,
            wsAccent: wsAccent,
            workspaceId: _project?.workspaceId,
            onSettings: _handleSettings,
          ),
          floatingActionButton: KanbanScreenFab(
            isArchived: isEffectivelyArchived,
            voiceCubit: voiceCubit,
            projectId: widget.projectId,
            workspaceId: _project?.workspaceId ?? 0,
            onOpenCreateTask: _openCreateTask,
          ),
          body: bodyContent,
        );
      },
      ),
    );
  }
}
