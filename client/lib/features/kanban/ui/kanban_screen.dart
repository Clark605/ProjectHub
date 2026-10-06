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
import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanScreen extends StatefulWidget {
  final int projectId;
  final KanbanCubit? cubit;
  final VoiceTaskCubit? voiceCubit;
  final ProjectDto? initialProject;

  const KanbanScreen({
    super.key,
    required this.projectId,
    this.cubit,
    this.voiceCubit,
    this.initialProject,
  });

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen>
    with WidgetsBindingObserver {
  late KanbanCubit _cubit;
  ProjectDto? _project;
  bool _didInit = false;
  late final PageController _pageController;

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
      if (widget.initialProject != null) {
        _cubit.setProject(widget.initialProject!);
      }
      _cubit.loadTasks(widget.projectId);
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

  Future<void> _handleSettings() async {
    final updated = await KanbanScreenActions.openSettings(
      context,
      widget.projectId,
    );
    if (updated != null && mounted) {
      setState(() => _project = updated);
      _cubit.setProject(updated);
    }
  }

  void _openCreateTask([String status = 'Backlog']) {
    KanbanScreenActions.openCreateTask(
      context,
      projectId: widget.projectId,
      members: _cubit.members,
      cubit: _cubit,
      status: status,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final voiceCubit = KanbanScreenActions.getVoiceCubit(
      context,
      widget.voiceCubit,
    );

    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<KanbanCubit, KanbanState>(
        bloc: widget.cubit != null ? _cubit : null,
        listener: (context, state) {
          final err = state.errorMessage;
          if (err != null && err.isNotEmpty) {
            KanbanScreenActions.showError(context, err, _cubit);
          }
        },
        builder: (context, state) {
          final project = _cubit.project ?? _project;
          final projectName =
              project?.name ??
              (state is KanbanLoading
                  ? '...'
                  : (l10n?.projectsTitle ?? 'Project'));
          final isEffectivelyArchived = state.isArchived || _cubit.isArchived;
          final wsAccent = KanbanScreenActions.getWorkspaceAccent(context);
          final members = _cubit.members;

          Widget bodyContent = KanbanViewBody(
            state: state,
            projectId: widget.projectId,
            isArchived: isEffectivelyArchived,
            wsAccent: wsAccent,
            pageController: _pageController,
            members: members,
            cubit: _cubit,
            onAddTask: (s) => _openCreateTask(s.toServerString()),
            onTaskTap: (t) => KanbanScreenActions.openTaskDetail(
              context,
              task: t,
              isArchived: isEffectivelyArchived,
              members: members,
              cubit: _cubit,
            ),
            onTaskMove: (t) => KanbanScreenActions.openMoveToStatus(
              context,
              task: t,
              cubit: _cubit,
            ),
            onTaskDelete: (t) =>
                KanbanScreenActions.confirmAndDeleteTask(context, t, _cubit),
          );

          if (voiceCubit != null) {
            bodyContent = KanbanVoiceHandler(
              projectId: widget.projectId,
              workspaceId: project?.workspaceId ?? 0,
              members: members,
              kanbanCubit: _cubit,
              child: bodyContent,
            );
          }

          return Scaffold(
            appBar: KanbanAppBar(
              projectName: projectName,
              wsAccent: wsAccent,
              workspaceId: project?.workspaceId,
              onSettings: _handleSettings,
            ),
            floatingActionButton: KanbanScreenFab(
              isArchived: isEffectivelyArchived,
              voiceCubit: voiceCubit,
              projectId: widget.projectId,
              workspaceId: project?.workspaceId ?? 0,
              onOpenCreateTask: _openCreateTask,
            ),
            body: bodyContent,
          );
        },
      ),
    );
  }
}
