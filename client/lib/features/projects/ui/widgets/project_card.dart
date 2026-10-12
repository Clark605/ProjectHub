import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_radius.dart';
import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/utils/date_formatter.dart';
import 'package:client/core/widgets/app_avatar.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class ProjectCard extends StatelessWidget {
  final ProjectDto project;
  final VoidCallback? onTap;

  const ProjectCard({super.key, required this.project, this.onTap});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'planning':
        return AppColors.skyBlue;
      case 'completed':
        return AppColors.electricViolet;
      case 'archived':
        return AppColors.textTertiary;
      default:
        return AppColors.skyBlue;
    }
  }

  String _getLocalizedStatus(BuildContext context, String status) {
    final l10n = context.l10n;
    switch (status.toLowerCase()) {
      case 'planning':
        return l10n.statusPlanning;
      case 'active':
        return l10n.statusActive;
      case 'completed':
        return l10n.statusCompleted;
      case 'archived':
        return l10n.statusArchived;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(project.status);

    final totalTasks = project.taskCounts.total;
    final doneTasks = project.taskCounts.done;
    final progress = totalTasks > 0
        ? (doneTasks / totalTasks).clamp(0.0, 1.0)
        : 0.0;
    final members = project.members;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lg,
      child: Ink(
        padding: AppSpacing.edgeInsetsAllLg,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.lg,
          border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AppSpacing.gapWSm,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: AppRadius.xl,
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getLocalizedStatus(context, project.status),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapHXs,
            Text(
              project.description.isNotEmpty ? project.description : '—',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            AppSpacing.gapHMd,
            // Progress Bar & Task Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  totalTasks > 0
                      ? '$doneTasks of $totalTasks tasks completed'
                      : 'No tasks yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                if (totalTasks > 0)
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
            AppSpacing.gapHXs,
            ClipRRect(
              borderRadius: AppRadius.xs,
              child: LinearProgressIndicator(
                value: totalTasks > 0 ? progress : 0.0,
                minHeight: 5,
                backgroundColor: isDark
                    ? AppColors.surfaceContainerHighest
                    : AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0
                      ? AppColors.success
                      : AppColors.electricVioletContainer,
                ),
              ),
            ),
            if (members.isNotEmpty) ...[
              AppSpacing.gapHSm,
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length > 4 ? 4 : members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        return Align(
                          widthFactor: 0.75,
                          child: AppAvatar(
                            name: member.name,
                            size: 24,
                            border: Border.all(
                              color: theme.colorScheme.surfaceContainerLow,
                              width: 1.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (members.length > 4) ...[
                    AppSpacing.gapWXs,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: AppRadius.md,
                      ),
                      child: Text(
                        '+${members.length - 4}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            AppSpacing.gapHSm,
            const Divider(height: 1, thickness: 1),
            AppSpacing.gapHSm,
            Row(
              children: [
                if (project.dueDate != null) ...[
                  Icon(
                    Icons.calendar_today_outlined,
                    size: AppIconSize.xxs,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  AppSpacing.gapWXs,
                  Text(
                    DateFormatter.formatDate(
                      project.dueDate!,
                      context: context,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const Spacer(),
                if (project.createdByName.isNotEmpty ||
                    project.createdBy.isNotEmpty) ...[
                  Icon(
                    Icons.person_outline_rounded,
                    size: AppIconSize.xs,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  AppSpacing.gapWXs,
                  Flexible(
                    child: Text(
                      project.createdByName.isNotEmpty
                          ? project.createdByName
                          : project.createdBy,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
