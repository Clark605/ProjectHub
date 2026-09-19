import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/routes/route_providers.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/shell/ui/widgets/shell_responsive_scaffold.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/ui/widgets/quick_start_dialog.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_switcher_sheet.dart';

class MainShellScreen extends StatefulWidget {
  final int initialIndex;
  final ProjectsListCubit? projectsCubit;
  final WorkspaceContextCubit? workspaceCubit;

  const MainShellScreen({
    super.key,
    this.initialIndex = 0,
    this.projectsCubit,
    this.workspaceCubit,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _selectedIndex;
  int? _lastWorkspaceId;

  WorkspaceContextCubit? _resolveWsCubit() {
    if (widget.workspaceCubit != null) return widget.workspaceCubit;
    try {
      return context.read<WorkspaceContextCubit>();
    } catch (_) {
      if (getIt.isRegistered<WorkspaceContextCubit>()) {
        return getIt<WorkspaceContextCubit>();
      }
    }
    return null;
  }

  ProjectsListCubit? _resolveProjectsCubit() {
    if (widget.projectsCubit != null) return widget.projectsCubit;
    try {
      return context.read<ProjectsListCubit>();
    } catch (_) {
      if (getIt.isRegistered<ProjectsListCubit>()) {
        return getIt<ProjectsListCubit>();
      }
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final wsCubit = _resolveWsCubit();
      if (wsCubit != null) {
        wsCubit.loadWorkspaces();
        final activeWs = wsCubit.state.whenOrNull(loaded: (_, active) => active);
        if (activeWs != null) {
          _lastWorkspaceId = activeWs.id;
          try {
            _resolveProjectsCubit()?.loadProjects(activeWs.id);
          } catch (_) {}
        }
        wsCubit.state.whenOrNull(
          empty: () => QuickStartDialog.show(context),
        );
      }
    });
  }

  void _onSelectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onProjectSelected(int projectId) {
    setState(() => _selectedIndex = 1);
    Navigator.of(context).pushNamed(RouteNames.projectDetail, arguments: projectId);
  }

  void _onWorkspaceTap(BuildContext context) {
    final wsCubit = _resolveWsCubit();
    final hasWorkspaces = wsCubit?.state.maybeWhen(
      loaded: (workspaces, _) => workspaces.isNotEmpty,
      orElse: () => false,
    ) ?? false;
    if (hasWorkspaces) {
      WorkspaceSwitcherSheet.show(context);
    } else {
      QuickStartDialog.show(context);
    }
  }

  void _onSettingsTap() {
    Navigator.of(context).pushNamed(RouteNames.workspaces);
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        for (int i = 0; i < 4; i++)
          buildShellTabContent(i, onSelectTab: _onSelectTab),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectsCubit = _resolveProjectsCubit();
    final wsCubit = _resolveWsCubit();

    Widget content = BlocConsumer<WorkspaceContextCubit, WorkspaceContextState>(
      bloc: wsCubit,
      listener: (context, state) {
        state.whenOrNull(
          empty: () => QuickStartDialog.show(context),
          loaded: (_, active) {
            if (active.id != _lastWorkspaceId) {
              _lastWorkspaceId = active.id;
              try {
                _resolveProjectsCubit()?.loadProjects(active.id);
              } catch (_) {}
            }
          },
        );
      },
      builder: (context, workspaceState) {
        final activeWorkspace = workspaceState.whenOrNull(loaded: (_, active) => active);
        final isWsLoading = workspaceState.maybeWhen(
          loading: () => true,
          initial: () => true,
          orElse: () => false,
        ) && activeWorkspace == null;

        return ShellResponsiveScaffold(
          selectedIndex: _selectedIndex,
          onSelectTab: _onSelectTab,
          onProjectSelected: _onProjectSelected,
          wsName: activeWorkspace?.name,
          wsRole: activeWorkspace?.membership?.role,
          wsAccent: activeWorkspace?.accentColor,
          isWsLoading: isWsLoading,
          onWorkspaceTap: () => _onWorkspaceTap(context),
          onSettingsTap: _onSettingsTap,
          body: _buildBody(),
        );
      },
    );

    if (projectsCubit != null) {
      content = BlocProvider.value(value: projectsCubit, child: content);
    }
    if (wsCubit != null) {
      content = BlocProvider.value(value: wsCubit, child: content);
    }
    return content;
  }
}
