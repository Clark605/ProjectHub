import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/profile/ui/profile_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    final cubit = getIt<WorkspaceContextCubit>();
    cubit.state.maybeWhen(
      initial: () => cubit.loadWorkspaces(),
      empty: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) QuickStartDialog.show(context);
        });
      },
      orElse: () {},
    );
  }

  void _onSelectTab(int index) {
    setState(() => _selectedIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  void _onWorkspaceTap() {
    final hasWorkspaces = getIt<WorkspaceContextCubit>().state.maybeWhen(
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
    switch (_selectedIndex) {
      case 0:
        return const ProjectsScreen();
      case 1:
        return const MyTasksScreen();
      case 2:
        return const ProfileScreen();
      default:
        return const ProjectsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<WorkspaceContextCubit>(),
      child: BlocConsumer<WorkspaceContextCubit, WorkspaceContextState>(
        listener: (context, state) {
          state.whenOrNull(empty: () => QuickStartDialog.show(context));
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
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            ShellTopBar(
                              activeWorkspaceName: wsName,
                              activeWorkspaceRole: wsRole,
                              isLoading: isWsLoading,
                              onWorkspaceTap: _onWorkspaceTap,
                              onSettingsTap: _onSettingsTap,
                              onProfileTap: () => _onSelectTab(2),
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
                    child: Sidebar(
                      selectedIndex: _selectedIndex,
                      onItemSelected: _onSelectTab,
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
                              onWorkspaceTap: _onWorkspaceTap,
                              onSettingsTap: _onSettingsTap,
                              onOpenDrawer: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                              onProfileTap: () => _onSelectTab(2),
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
                    child: Sidebar(
                      selectedIndex: _selectedIndex,
                      onItemSelected: _onSelectTab,
                    ),
                  ),
                  appBar: ShellTopBar(
                    activeWorkspaceName: wsName,
                    activeWorkspaceRole: wsRole,
                    isLoading: isWsLoading,
                    onWorkspaceTap: _onWorkspaceTap,
                    onSettingsTap: _onSettingsTap,
                    onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                    onProfileTap: () => _onSelectTab(2),
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
      ),
    );
  }
}
