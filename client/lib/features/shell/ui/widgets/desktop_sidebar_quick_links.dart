import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/project_status.dart';

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
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
  final List<ProjectDto> projects;
  final bool isLoading;
  final ValueChanged<int>? onProjectSelected;

  const DesktopSidebarQuickLinks({
    super.key,
    required this.projects,
    this.isLoading = false,
    this.onProjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeProjects = projects
        .where((p) => p.statusEnum == ProjectStatus.active)
        .toList();
    final displayProjects = activeProjects.isNotEmpty
        ? activeProjects.take(6).toList()
        : projects.take(6).toList();

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
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (displayProjects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'No projects yet',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          )
        else
          ...displayProjects.map((project) {
            final color = project.statusEnum.toColor(context);
            return DesktopSidebarProjectQuickLink(
              title: project.name,
              color: color,
              onTap: () => onProjectSelected?.call(project.id),
            );
          }),
      ],
    );
  }
}
