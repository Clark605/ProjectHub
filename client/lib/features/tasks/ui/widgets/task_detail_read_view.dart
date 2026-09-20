import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/comments/cubit/comments_cubit.dart';
import 'package:client/features/comments/data/comment_repository.dart';
import 'package:client/features/comments/ui/widgets/task_comments_list.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tags/ui/widgets/task_tags_row.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class TaskDetailReadView extends StatelessWidget {
  final TaskDto task;
  final bool isArchived;
  final String currentUserId;
  final bool isWorkspaceOwner;
  final ValueChanged<TagDto>? onTagAdded;
  final ValueChanged<TagDto>? onTagRemoved;

  const TaskDetailReadView({
    super.key,
    required this.task,
    this.isArchived = false,
    this.currentUserId = '',
    this.isWorkspaceOwner = false,
    this.onTagAdded,
    this.onTagRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isOverdue = task.isOverdue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          task.description.isNotEmpty
              ? task.description
              : (l10n?.noDescriptionProvided ?? 'No description provided.'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: task.description.isNotEmpty
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant,
            fontStyle: task.description.isEmpty
                ? FontStyle.italic
                : FontStyle.normal,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        TaskTagsRow(
          projectId: task.projectId,
          tags: task.tags,
          canEdit: !isArchived,
          onTagAdded: onTagAdded,
          onTagRemoved: onTagRemoved,
        ),
        const SizedBox(height: 16),
        Divider(height: 1, color: theme.colorScheme.outlineVariant),
        const SizedBox(height: 16),
        _buildInfoRow(
          context,
          icon: Icons.person_outline_rounded,
          label: l10n?.assignee ?? 'Assignee',
          value: task.assigneeName ?? (l10n?.unassigned ?? 'Unassigned'),
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          icon: Icons.calendar_today_outlined,
          label: l10n?.dueDate ?? 'Due Date',
          value: task.dueDate != null
              ? DateFormat('MMMM d, yyyy').format(task.dueDate!)
              : (l10n?.dueDateNotSet ?? 'Not set'),
          valueColor: isOverdue ? AppColors.error : null,
          trailing: isOverdue ? _buildOverdueBadge(l10n) : null,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          context,
          icon: Icons.history_edu_rounded,
          label: l10n?.taskCreatedBy ?? 'Created By',
          value: task.createdByName.isNotEmpty
              ? task.createdByName
              : (l10n?.unknownUser ?? 'Unknown'),
        ),
        if (task.createdAt != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            context,
            icon: Icons.access_time_rounded,
            label: l10n?.taskCreatedAt ?? 'Created',
            value: DateFormat(
              'MMM d, yyyy • h:mm a',
            ).format(task.createdAt!.toLocal()),
          ),
        ],
        if (getIt.isRegistered<CommentRepository>()) ...[
          const SizedBox(height: 20),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          BlocProvider<CommentsCubit>(
            create: (_) => CommentsCubit(
              taskId: task.id,
              repository: getIt<CommentRepository>(),
              signalRService: getIt.isRegistered<SignalRService>()
                  ? getIt<SignalRService>()
                  : null,
            ),
            child: TaskCommentsList(
              currentUserId: currentUserId,
              isWorkspaceOwner: isWorkspaceOwner,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOverdueBadge(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        l10n?.taskOverdue ?? 'Overdue',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.error,
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
  }
}
