import 'package:flutter/material.dart';

import 'package:client/core/utils/responsive_layout.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/features/shell/ui/widgets/mobile_bottom_nav.dart';
import 'package:client/features/shell/ui/widgets/shell_top_bar.dart';
import 'package:client/features/shell/ui/widgets/sidebar.dart';
import 'package:client/features/shell/ui/widgets/tablet_navigation_rail.dart';

class ShellResponsiveScaffold extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectTab;
  final ValueChanged<int> onProjectSelected;
  final String? wsName;
  final String? wsRole;
  final String? wsAccent;
  final bool isWsLoading;
  final VoidCallback onWorkspaceTap;
  final VoidCallback onSettingsTap;
  final Widget body;

  const ShellResponsiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onSelectTab,
    required this.onProjectSelected,
    required this.wsName,
    required this.wsRole,
    required this.wsAccent,
    required this.isWsLoading,
    required this.onWorkspaceTap,
    required this.onSettingsTap,
    required this.body,
  });

  @override
  State<ShellResponsiveScaffold> createState() => _ShellResponsiveScaffoldState();
}

class _ShellResponsiveScaffoldState extends State<ShellResponsiveScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _handleTabSelect(int index) {
    widget.onSelectTab(index);
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
  }

  void _handleProjectSelect(int projectId) {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
    widget.onProjectSelected(projectId);
  }

  Widget _buildSidebar() {
    return Sidebar(
      selectedIndex: widget.selectedIndex,
      onItemSelected: _handleTabSelect,
      onProjectSelected: _handleProjectSelect,
      activeWorkspaceName: widget.wsName,
      activeWorkspaceAccent: widget.wsAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: AmbientGlowBackground(
        child: ResponsiveLayout(
          desktop: Scaffold(
            backgroundColor: Colors.transparent,
            body: Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: Column(
                    children: [
                      ShellTopBar(
                        activeWorkspaceName: widget.wsName,
                        activeWorkspaceRole: widget.wsRole,
                        activeWorkspaceAccent: widget.wsAccent,
                        isLoading: widget.isWsLoading,
                        onWorkspaceTap: widget.onWorkspaceTap,
                        onSettingsTap: widget.onSettingsTap,
                      ),
                      Expanded(child: widget.body),
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
              backgroundColor: theme.colorScheme.surface,
              child: _buildSidebar(),
            ),
            body: Row(
              children: [
                TabletNavigationRail(
                  selectedIndex: widget.selectedIndex,
                  onItemSelected: _handleTabSelect,
                ),
                Expanded(
                  child: Column(
                    children: [
                      ShellTopBar(
                        activeWorkspaceName: widget.wsName,
                        activeWorkspaceRole: widget.wsRole,
                        activeWorkspaceAccent: widget.wsAccent,
                        isLoading: widget.isWsLoading,
                        onWorkspaceTap: widget.onWorkspaceTap,
                        onSettingsTap: widget.onSettingsTap,
                        onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      Expanded(child: widget.body),
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
              backgroundColor: theme.colorScheme.surface,
              child: _buildSidebar(),
            ),
            appBar: ShellTopBar(
              activeWorkspaceName: widget.wsName,
              activeWorkspaceRole: widget.wsRole,
              activeWorkspaceAccent: widget.wsAccent,
              isLoading: widget.isWsLoading,
              onWorkspaceTap: widget.onWorkspaceTap,
              onSettingsTap: widget.onSettingsTap,
              onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            body: widget.body,
            bottomNavigationBar: MobileBottomNav(
              selectedIndex: widget.selectedIndex,
              onItemSelected: _handleTabSelect,
              activeWorkspaceAccent: widget.wsAccent,
            ),
          ),
        ),
      ),
    );
  }
}
