import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';

class TabletNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const TabletNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        border: const Border(
          right: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Logo Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.electricViolet, AppColors.skyBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(
                Icons.hub_rounded,
                color: AppColors.onElectricViolet,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),

          // Rail Nav Items
          _RailItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          const SizedBox(height: 12),
          _RailItem(
            icon: Icons.folder_rounded,
            label: 'Projects',
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          const SizedBox(height: 12),
          _RailItem(
            icon: Icons.task_alt_rounded,
            label: 'My Tasks',
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(2),
          ),
          const SizedBox(height: 12),
          _RailItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            isSelected: selectedIndex == 3,
            onTap: () => onItemSelected(3),
          ),

          const Spacer(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RailItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  )
                : null,
          ),
          child: Icon(
            icon,
            size: 22,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
