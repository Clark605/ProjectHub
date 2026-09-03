import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';

class DesktopSidebarProjectQuickLink extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const DesktopSidebarProjectQuickLink({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DesktopSidebarQuickLinks extends StatelessWidget {
  final ValueChanged<int> onItemSelected;

  const DesktopSidebarQuickLinks({
    super.key,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'ACTIVE PROJECTS',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: 8),
        DesktopSidebarProjectQuickLink(
          title: 'Mobile Client v1',
          color: AppColors.electricViolet,
          onTap: () => onItemSelected(0),
        ),
        DesktopSidebarProjectQuickLink(
          title: 'Design System',
          color: AppColors.skyBlue,
          onTap: () => onItemSelected(0),
        ),
        DesktopSidebarProjectQuickLink(
          title: 'Backend API 10',
          color: AppColors.warning,
          onTap: () => onItemSelected(0),
        ),
      ],
    );
  }
}
