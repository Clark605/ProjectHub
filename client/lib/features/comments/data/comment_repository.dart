import 'package:client/features/comments/data/models/comment_dto.dart';

abstract class CommentRepository {
  Future<List<CommentDto>> getComments(int taskId);
  Future<CommentDto> createComment(int taskId, String content);
  Future<CommentDto> updateComment(int commentId, String content);
  Future<void> deleteComment(int commentId);
}
