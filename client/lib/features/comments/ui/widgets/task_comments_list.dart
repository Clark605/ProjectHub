import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/features/comments/cubit/comments_cubit.dart';
import 'package:client/features/comments/cubit/comments_state.dart';
import 'package:client/features/comments/ui/widgets/task_comment_input.dart';
import 'package:client/features/comments/ui/widgets/task_comment_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return BlocBuilder<CommentsCubit, CommentsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: AppSpacing.xxl,
                height: AppSpacing.xxl,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (failure) => Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              l10n.failedToLoadComments(failure.toLocalizedMessage(l10n)),
              style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error),
            ),
          ),
          loaded: (comments, isSending, failure) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: AppIconSize.sm,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    AppSpacing.gapWXs,
                    Text(
                      l10n.commentsCount(comments.length),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapHSm,
                if (failure != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      failure.toLocalizedMessage(l10n),
                      style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.error),
                    ),
                  ),
                if (comments.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: Text(
                      l10n.noCommentsYet,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
                AppSpacing.gapHMd,
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
