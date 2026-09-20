import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:client/features/comments/data/models/comment_dto.dart';

part 'comments_state.freezed.dart';

@freezed
abstract class CommentsState with _$CommentsState {
  const factory CommentsState.initial() = _CommentsInitial;
  const factory CommentsState.loading() = _CommentsLoading;
  const factory CommentsState.loaded({
    required List<CommentDto> comments,
    @Default(false) bool isSending,
    String? errorMessage,
  }) = CommentsLoaded;
  const factory CommentsState.error(String message) = _CommentsError;
}
