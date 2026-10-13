import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/project_status.dart';
import 'package:client/features/projects/ui/extensions/project_status_ui.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_spacing.dart';

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
      borderRadius: AppRadius.sm,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            AppSpacing.gapWSm,
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    final l10n = context.l10n;
    final activeProjects = projects
        .where((p) => p.statusEnum == ProjectStatus.active)
        .toList();
    final displayProjects = activeProjects.isNotEmpty
        ? activeProjects.take(6).toList()
        : projects.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.gapHXxl,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            l10n.activeProjectsSection,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ),
        AppSpacing.gapHSm,
        if (isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: SizedBox(
              width: AppIconSize.xs,
              height: AppIconSize.xs,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (displayProjects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              l10n.noProjectsYet,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
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
