import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  const MainShellScreen({super.key, this.initialIndex = 0});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _selectedIndex;
  int? _lastWorkspaceId;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final wsCubit = context.read<WorkspaceContextCubit>();
      wsCubit.loadWorkspaces();
      final activeWs = wsCubit.state.whenOrNull(loaded: (_, active) => active);
      if (activeWs != null) {
        _lastWorkspaceId = activeWs.id;
        context.read<ProjectsListCubit>().loadProjects(activeWs.id);
      }
      wsCubit.state.whenOrNull(empty: () => QuickStartDialog.show(context));
    });
  }

  void _onSelectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _onProjectSelected(int projectId) {
    setState(() => _selectedIndex = 1);
    Navigator.of(
      context,
    ).pushNamed(RouteNames.projectDetail, arguments: projectId);
  }

  void _onWorkspaceTap(BuildContext context) {
    final wsCubit = context.read<WorkspaceContextCubit>();
    final hasWorkspaces = wsCubit.state.maybeWhen(
      loaded: (workspaces, _) => workspaces.isNotEmpty,
      orElse: () => false,
    );
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
    return BlocConsumer<WorkspaceContextCubit, WorkspaceContextState>(
      listener: (context, state) {
        state.whenOrNull(
          empty: () => QuickStartDialog.show(context),
          loaded: (_, active) {
            if (active.id != _lastWorkspaceId) {
              _lastWorkspaceId = active.id;
              context.read<ProjectsListCubit>().loadProjects(active.id);
            }
          },
        );
      },
      builder: (context, workspaceState) {
        final activeWorkspace = workspaceState.whenOrNull(
          loaded: (_, active) => active,
        );
        final isWsLoading =
            workspaceState.maybeWhen(
              loading: () => true,
              initial: () => true,
              orElse: () => false,
            ) &&
            activeWorkspace == null;

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
  }
}
