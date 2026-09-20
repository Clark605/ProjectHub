import 'package:injectable/injectable.dart';

import 'package:client/features/comments/data/comment_remote_data_source.dart';
import 'package:client/features/comments/data/comment_repository.dart';
import 'package:client/features/comments/data/models/comment_dto.dart';

@LazySingleton(as: CommentRepository)
class CommentRepositoryImpl implements CommentRepository {
  CommentRepositoryImpl(this._remoteDataSource);

  final CommentRemoteDataSource _remoteDataSource;

  @override
  Future<List<CommentDto>> getComments(int taskId) =>
      _remoteDataSource.getComments(taskId);

  @override
  Future<CommentDto> createComment(int taskId, String content) =>
      _remoteDataSource.createComment(taskId, content);

  @override
  Future<CommentDto> updateComment(int commentId, String content) =>
      _remoteDataSource.updateComment(commentId, content);

  @override
  Future<void> deleteComment(int commentId) =>
      _remoteDataSource.deleteComment(commentId);
}
