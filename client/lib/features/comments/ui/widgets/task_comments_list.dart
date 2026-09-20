import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/comments/cubit/comments_cubit.dart';
import 'package:client/features/comments/cubit/comments_state.dart';
import 'package:client/features/comments/ui/widgets/task_comment_input.dart';
import 'package:client/features/comments/ui/widgets/task_comment_item.dart';

class TaskCommentsList extends StatelessWidget {
  const TaskCommentsList({
    super.key,
    required this.currentUserId,
    this.isWorkspaceOwner = false,
  });

  final String currentUserId;
  final bool isWorkspaceOwner;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (message) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Failed to load comments: $message',
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ),
          loaded: (comments, isSending, errorMessage) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Comments (${comments.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (comments.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'No comments yet. Start the conversation!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  ...comments.map(
                    (comment) => TaskCommentItem(
                      comment: comment,
                      currentUserId: currentUserId,
                      isWorkspaceOwner: isWorkspaceOwner,
                      onDelete: () => context
                          .read<CommentsCubit>()
                          .deleteComment(comment.id),
                    ),
                  ),
                const SizedBox(height: 12),
                TaskCommentInput(
                  isSending: isSending,
                  onSend: (text) =>
                      context.read<CommentsCubit>().addComment(text),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
