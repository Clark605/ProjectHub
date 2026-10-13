import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_avatar_size.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/core/utils/date_formatter.dart';
import 'package:client/core/widgets/app_avatar.dart';
import 'package:client/features/comments/data/models/comment_dto.dart';
import 'package:flutter/material.dart';

class TaskCommentItem extends StatelessWidget {
  const TaskCommentItem({
    super.key,
    required this.comment,
    required this.currentUserId,
    this.isWorkspaceOwner = false,
    required this.onDelete,
  });

  final CommentDto comment;
  final String currentUserId;
  final bool isWorkspaceOwner;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final canDelete = comment.authorId == currentUserId || isWorkspaceOwner;
    final timeStr = DateFormatter.formatRelativeTime(
      comment.createdAt,
      context: context,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(name: comment.authorName, size: AppAvatarSize.sm),
          AppSpacing.gapWSm,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    AppSpacing.gapWXs,
                    Text(
                      timeStr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (canDelete)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: AppIconSize.sm,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onDelete,
                        tooltip: l10n.deleteCommentTooltip,
                      ),
                  ],
                ),
                AppSpacing.gapHXxs,
                Text(
                  comment.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
