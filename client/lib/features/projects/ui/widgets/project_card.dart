import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:client/core/theme/app_colors.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
    final statusColor = _getStatusColor(project.status);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 8),
            Text(
              project.description.isNotEmpty ? project.description : '—',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                if (project.dueDate != null) ...[
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat.yMMMd().format(project.dueDate!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                ] else
                  const Spacer(),
                if (project.createdByName.isNotEmpty ||
                    project.createdBy.isNotEmpty) ...[
                  Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    project.createdByName.isNotEmpty
                        ? project.createdByName
                        : project.createdBy,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
