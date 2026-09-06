import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_nav_item.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_quick_links.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_user_profile.dart';

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

          // Navigation Section (3 Tabs: Projects, My Tasks, Profile)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                DesktopSidebarNavItem(
                  icon: Icons.folder_rounded,
                  label: 'Projects',
                  isSelected: selectedIndex == 0,
                  badge: '3',
                  onTap: () => onItemSelected(0),
                ),
                const SizedBox(height: 4),
                DesktopSidebarNavItem(
                  icon: Icons.task_alt_rounded,
                  label: 'My Tasks',
                  isSelected: selectedIndex == 1,
                  badge: '5',
                  badgeColor: AppColors.priorityUrgent,
                  onTap: () => onItemSelected(1),
                ),
                const SizedBox(height: 4),
                DesktopSidebarNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile & Settings',
                  isSelected: selectedIndex == 2,
                  onTap: () => onItemSelected(2),
                ),
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
