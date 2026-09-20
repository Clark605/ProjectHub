import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/comments/data/models/comment_dto.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentDto>> getComments(int taskId);
  Future<CommentDto> createComment(int taskId, String content);
  Future<CommentDto> updateComment(int commentId, String content);
  Future<void> deleteComment(int commentId);
}

@LazySingleton(as: CommentRemoteDataSource)
class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  CommentRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  Future<T> _guard<T>(String op, Future<T> Function() call) async {
    try {
      AppLogger.info(op, tag: 'CommentRemoteDataSource');
      final result = await call();
      AppLogger.debug('Success: $op', tag: 'CommentRemoteDataSource');
      return result;
    } on DioException catch (e) {
      AppLogger.error('Failed: $op', error: e, tag: 'CommentRemoteDataSource');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<List<CommentDto>> getComments(int taskId) {
    return _guard('Fetching comments for task $taskId', () async {
      final res = await _dio.get<List<dynamic>>(
        ApiConstants.taskComments(taskId),
      );
      return (res.data ?? [])
          .map((e) => CommentDto.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<CommentDto> createComment(int taskId, String content) {
    return _guard('Creating comment on task $taskId', () async {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiConstants.taskComments(taskId),
        data: {'content': content},
      );
      return CommentDto.fromJson(res.data!);
    });
  }

  @override
  Future<CommentDto> updateComment(int commentId, String content) {
    return _guard('Updating comment $commentId', () async {
      final res = await _dio.put<Map<String, dynamic>>(
        ApiConstants.commentById(commentId),
        data: {'content': content},
      );
      return CommentDto.fromJson(res.data!);
    });
  }

  @override
  Future<void> deleteComment(int commentId) {
    return _guard('Deleting comment $commentId', () async {
      await _dio.delete<void>(ApiConstants.commentById(commentId));
    });
  }
}
