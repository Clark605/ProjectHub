import 'package:flutter/material.dart';

import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/dashboard/ui/dashboard_screen.dart';
import 'package:client/features/profile/ui/profile_screen.dart';
import 'package:client/features/projects/ui/projects_screen.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar.dart';
import 'package:client/features/shell/ui/widgets/mobile_bottom_nav.dart';
import 'package:client/features/shell/ui/widgets/shell_top_bar.dart';
import 'package:client/features/shell/ui/widgets/tablet_navigation_rail.dart';
import 'package:client/features/tasks/ui/my_tasks_screen.dart';

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
  }

  void _onSelectTab(int index) {
    setState(() => _selectedIndex = index);
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          onNavigateToProjects: () => _onSelectTab(1),
          onNavigateToMyTasks: () => _onSelectTab(2),
        );
      case 1:
        return const ProjectsScreen();
      case 2:
        return const MyTasksScreen();
      case 3:
        return const ProfileScreen();
      default:
        return DashboardScreen(
          onNavigateToProjects: () => _onSelectTab(1),
          onNavigateToMyTasks: () => _onSelectTab(2),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AmbientGlowBackground(
      child: ResponsiveLayout(
        // ── Desktop Layout: 240px Sidebar + Top Bar + Content ──
        desktop: Scaffold(
          backgroundColor: Colors.transparent,
          body: Row(
            children: [
              DesktopSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: _onSelectTab,
              ),
              Expanded(
                child: Column(
                  children: [
                    ShellTopBar(
                      onProfileTap: () => _onSelectTab(3),
                    ),
                    Expanded(child: _buildBody()),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Tablet Layout: 72px Navigation Rail + Top Bar + Content ──
        tablet: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          drawer: Drawer(
            child: DesktopSidebar(
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
                      onOpenDrawer: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                      onProfileTap: () => _onSelectTab(3),
                    ),
                    Expanded(child: _buildBody()),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Mobile Layout: Top Bar + Content + Bottom Nav + Drawer ──
        mobile: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          drawer: Drawer(
            child: DesktopSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: _onSelectTab,
            ),
          ),
          appBar: ShellTopBar(
            onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
            onProfileTap: () => _onSelectTab(3),
          ),
          body: _buildBody(),
          bottomNavigationBar: MobileBottomNav(
            selectedIndex: _selectedIndex,
            onItemSelected: _onSelectTab,
          ),
        ),
      ),
    );
  }
}
