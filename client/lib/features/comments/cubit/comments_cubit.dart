import 'dart:async';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/network/signalr_events.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/features/comments/cubit/comments_state.dart';
import 'package:client/features/comments/data/comment_repository.dart';
import 'package:client/features/comments/data/models/comment_dto.dart';

class CommentsCubit extends SafeActionCubit<CommentsState> {
  CommentsCubit({
    required this.taskId,
    required CommentRepository repository,
    SignalRService? signalRService,
  }) : _repository = repository,
       _signalRService = signalRService,
       super(const CommentsState.initial()) {
    _initRealtime();
    loadComments();
  }

  final int taskId;
  final CommentRepository _repository;
  final SignalRService? _signalRService;

  StreamSubscription<CommentAddedEvent>? _commentAddedSub;
  StreamSubscription<CommentDeletedEvent>? _commentDeletedSub;

  void _initRealtime() {
    final service = _signalRService;
    if (service == null) return;
    _commentAddedSub = service.commentAdded.listen((comment) {
      if (comment.taskId == taskId) {
        _onCommentAdded(comment);
      }
    });

    _commentDeletedSub = service.commentDeleted.listen((event) {
      if (event.taskId == taskId) {
        _onCommentDeleted(event.commentId);
      }
    });
  }

  void _onCommentAdded(CommentDto comment) {
    state.maybeWhen(
      loaded: (comments, isSending, errorMessage) {
        if (!comments.any((c) => c.id == comment.id)) {
          emit(
            CommentsState.loaded(
              comments: [...comments, comment],
              isSending: isSending,
            ),
          );
        }
      },
      orElse: () {},
    );
  }

  void _onCommentDeleted(int commentId) {
    state.maybeWhen(
      loaded: (comments, isSending, errorMessage) {
        emit(
          CommentsState.loaded(
            comments: comments.where((c) => c.id != commentId).toList(),
            isSending: isSending,
          ),
        );
      },
      orElse: () {},
    );
  }

  Future<void> loadComments() async {
    emit(const CommentsState.loading());
    await safeExecute(
      () async {
        final comments = await _repository.getComments(taskId);
        emit(CommentsState.loaded(comments: comments));
      },
      onError: (err) => emit(CommentsState.error(err)),
      defaultErrorMessage: 'Failed to load comments',
      logTag: 'CommentsCubit',
    );
  }

  Future<bool> addComment(String content) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return false;

    final currentComments = state.maybeWhen(
      loaded: (comments, _, _) => comments,
      orElse: () => <CommentDto>[],
    );

    emit(CommentsState.loaded(comments: currentComments, isSending: true));
    final result = await safeExecute<bool>(
      () async {
        final newComment = await _repository.createComment(taskId, trimmed);
        final exists = currentComments.any((c) => c.id == newComment.id);
        final updated = exists
            ? currentComments
            : [...currentComments, newComment];
        emit(CommentsState.loaded(comments: updated, isSending: false));
        return true;
      },
      onError: (err) {
        emit(
          CommentsState.loaded(
            comments: currentComments,
            isSending: false,
            errorMessage: err,
          ),
        );
      },
      defaultErrorMessage: 'Failed to post comment',
      logTag: 'CommentsCubit',
    );
    return result ?? false;
  }

  Future<void> deleteComment(int commentId) async {
    final currentComments = state.maybeWhen(
      loaded: (comments, _, _) => comments,
      orElse: () => <CommentDto>[],
    );

    await safeExecute(
      () async {
        await _repository.deleteComment(commentId);
        emit(
          CommentsState.loaded(
            comments: currentComments.where((c) => c.id != commentId).toList(),
          ),
        );
      },
      onError: (err) {
        emit(
          CommentsState.loaded(
            comments: currentComments,
            errorMessage: err,
          ),
        );
      },
      defaultErrorMessage: 'Failed to delete comment',
      logTag: 'CommentsCubit',
    );
  }

  @override
  Future<void> close() {
    _commentAddedSub?.cancel();
    _commentDeletedSub?.cancel();
    return super.close();
  }
}
