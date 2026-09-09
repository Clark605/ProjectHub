import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/dashboard/ui/dashboard_screen.dart';
import 'package:client/features/profile/ui/profile_screen.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/projects/ui/projects_screen.dart';
import 'package:client/features/shell/ui/widgets/sidebar.dart';
import 'package:client/features/shell/ui/widgets/mobile_bottom_nav.dart';
import 'package:client/features/shell/ui/widgets/shell_top_bar.dart';
import 'package:client/features/shell/ui/widgets/tablet_navigation_rail.dart';
import 'package:client/features/tasks/ui/my_tasks_screen.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ProjectsListCubit? _projectsListCubit;
  int? _lastWorkspaceId;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    if (getIt.isRegistered<ProjectsListCubit>()) {
      _projectsListCubit = getIt<ProjectsListCubit>();
    } else if (getIt.isRegistered<ProjectRepository>()) {
      _projectsListCubit = ProjectsListCubit(getIt<ProjectRepository>());
    }

    final cubit = getIt<WorkspaceContextCubit>();
    // Always trigger background revalidation (stale-while-revalidate)
    cubit.loadWorkspaces();
    final activeWs = cubit.state.whenOrNull(loaded: (_, active) => active);
    if (activeWs != null) {
      _lastWorkspaceId = activeWs.id;
      _projectsListCubit?.loadProjects(activeWs.id);
    }
    cubit.state.whenOrNull(
      empty: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) QuickStartDialog.show(context);
        });
      },
    );
  }

  @override
  void dispose() {
    if (!getIt.isRegistered<ProjectsListCubit>()) {
      _projectsListCubit?.close();
    }
    super.dispose();
  }

  void _onSelectTab(int index) {
    setState(() => _selectedIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  void _onProjectSelected(int projectId) {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
    setState(() => _selectedIndex = 1);
    Navigator.of(
      context,
    ).pushNamed(RouteNames.projectDetail, arguments: projectId);
  }

  void _onWorkspaceTap(BuildContext context) {
    final hasWorkspaces = context.read<WorkspaceContextCubit>().state.maybeWhen(
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
        DashboardScreen(
          onNavigateToProjects: () => setState(() => _selectedIndex = 1),
          onNavigateToMyTasks: () => setState(() => _selectedIndex = 2),
        ),
        ProjectsScreen(cubit: _projectsListCubit),
        const MyTasksScreen(),
        const ProfileScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = BlocConsumer<WorkspaceContextCubit, WorkspaceContextState>(
      listener: (context, state) {
        state.whenOrNull(
          empty: () => QuickStartDialog.show(context),
          loaded: (_, active) {
            if (active.id != _lastWorkspaceId) {
              _lastWorkspaceId = active.id;
              _projectsListCubit?.loadProjects(active.id);
            }
          },
        );
      },
      builder: (context, workspaceState) {
        final activeWorkspace = workspaceState.whenOrNull(
          loaded: (_, active) => active,
        );
        final wsName = activeWorkspace?.name;
        final wsRole = activeWorkspace?.membership?.role;
        final isWsLoading =
            workspaceState.maybeWhen(
              loading: () => true,
              initial: () => true,
              orElse: () => false,
            ) &&
            activeWorkspace == null;

        return SafeArea(
          child: AmbientGlowBackground(
            child: ResponsiveLayout(
              desktop: Scaffold(
                backgroundColor: Colors.transparent,
                body: Row(
                  children: [
                    Sidebar(
                      selectedIndex: _selectedIndex,
                      onItemSelected: _onSelectTab,
                      onProjectSelected: _onProjectSelected,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          ShellTopBar(
                            activeWorkspaceName: wsName,
                            activeWorkspaceRole: wsRole,
                            isLoading: isWsLoading,
                            onWorkspaceTap: () => _onWorkspaceTap(context),
                            onSettingsTap: _onSettingsTap,
                          ),
                          Expanded(child: _buildBody()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              tablet: Scaffold(
                key: _scaffoldKey,
                backgroundColor: Colors.transparent,
                drawer: Drawer(
                  width: 240,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Sidebar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: _onSelectTab,
                    onProjectSelected: _onProjectSelected,
                  ),
                ),
                body: Row(
                  children: [
                    TabletNavigationRail(
                      selectedIndex: _selectedIndex,
                      onItemSelected: _onSelectTab,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          ShellTopBar(
                            activeWorkspaceName: wsName,
                            activeWorkspaceRole: wsRole,
                            isLoading: isWsLoading,
                            onWorkspaceTap: () => _onWorkspaceTap(context),
                            onSettingsTap: _onSettingsTap,
                            onOpenDrawer: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                          ),
                          Expanded(child: _buildBody()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              mobile: Scaffold(
                key: _scaffoldKey,
                backgroundColor: Colors.transparent,
                drawer: Drawer(
                  width: 240,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Sidebar(
                    selectedIndex: _selectedIndex,
                    onItemSelected: _onSelectTab,
                    onProjectSelected: _onProjectSelected,
                  ),
                ),
                appBar: ShellTopBar(
                  activeWorkspaceName: wsName,
                  activeWorkspaceRole: wsRole,
                  isLoading: isWsLoading,
                  onWorkspaceTap: () => _onWorkspaceTap(context),
                  onSettingsTap: _onSettingsTap,
                  onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                body: _buildBody(),
                bottomNavigationBar: MobileBottomNav(
                  selectedIndex: _selectedIndex,
                  onItemSelected: _onSelectTab,
                ),
              ),
            ),
          ),
        );
      },
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<WorkspaceContextCubit>()),
        if (_projectsListCubit != null)
          BlocProvider.value(value: _projectsListCubit!),
      ],
      child: content,
    );
  }
}
