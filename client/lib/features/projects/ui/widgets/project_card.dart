import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/utils/date_formatter.dart';
import 'package:client/core/widgets/app_avatar.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
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
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
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
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
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
            const SizedBox(height: 6),
            Text(
              project.description.isNotEmpty ? project.description : '—',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Progress Bar & Task Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  totalTasks > 0
                      ? '$doneTasks of $totalTasks tasks completed'
                      : 'No tasks yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
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
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
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
              const SizedBox(height: 10),
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
                            userId: member.id,
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
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '+${members.length - 4}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 10),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                if (project.dueDate != null) ...[
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.formatDate(
                      project.dueDate!,
                      context: context,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
                const Spacer(),
                if (project.createdByName.isNotEmpty ||
                    project.createdBy.isNotEmpty) ...[
                  Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      project.createdByName.isNotEmpty
                          ? project.createdByName
                          : project.createdBy,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
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
