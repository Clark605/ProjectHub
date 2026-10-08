import 'package:flutter/material.dart';

import 'package:client/core/utils/date_formatter.dart';
import 'package:client/core/widgets/app_avatar.dart';
import 'package:client/features/comments/data/models/comment_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    final canDelete = comment.authorId == currentUserId || isWorkspaceOwner;
    final timeStr = DateFormatter.formatRelativeTime(
      comment.createdAt,
      context: context,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppAvatar(
            name: comment.authorName,
            userId: comment.authorId,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (canDelete)
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: onDelete,
                        tooltip: l10n.deleteCommentTooltip,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.content,
                  style: TextStyle(
                    fontSize: 13,
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
