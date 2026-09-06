import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_nav_item.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_quick_links.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_user_profile.dart';
import 'package:client/features/shell/models/shell_tab.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        border: const Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // App Brand Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.electricViolet, AppColors.skyBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.hub_rounded,
                      color: AppColors.onElectricViolet,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'ProjectHub',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),

          // Navigation Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                ...ShellTab.values.map((tab) => Column(
                      children: [
                        DesktopSidebarNavItem(
                          icon: tab.selectedIcon,
                          label: tab == ShellTab.profile ? 'Profile & Settings' : tab.label,
                          isSelected: selectedIndex == tab.index,
                          badge: tab == ShellTab.projects
                              ? '3'
                              : (tab == ShellTab.myTasks ? '5' : null),
                          badgeColor: tab == ShellTab.myTasks
                              ? AppColors.priorityUrgent
                              : null,
                          onTap: () => onItemSelected(tab.index),
                        ),
                        if (tab != ShellTab.profile) const SizedBox(height: 4),
                      ],
                    )),
                DesktopSidebarQuickLinks(onItemSelected: onItemSelected),
              ],
            ),
          ),

          // User Profile & Logout Footer
          const DesktopSidebarUserProfile(),
        ],
      ),
    );
  }
}
