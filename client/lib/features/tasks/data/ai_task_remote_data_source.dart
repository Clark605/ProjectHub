import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/tasks/data/models/parsed_task_draft_dto.dart';

abstract class AiTaskRemoteDataSource {
  Future<ParsedTaskDraftDto> parseTaskFromText({
    required String text,
    required int projectId,
    required int workspaceId,
  });
}

@LazySingleton(as: AiTaskRemoteDataSource)
class AiTaskRemoteDataSourceImpl implements AiTaskRemoteDataSource {
  final Dio _dio;

  AiTaskRemoteDataSourceImpl(this._dio);

  @override
  Future<ParsedTaskDraftDto> parseTaskFromText({
    required String text,
    required int projectId,
    required int workspaceId,
  }) async {
    const op = 'Parsing task from voice text via AI';
    try {
      AppLogger.info(op, tag: 'AiTaskRemoteDataSource');
      final response = await _dio.post<Map<String, dynamic>>(
        ApiConstants.aiParseTask,
        data: {
          'text': text,
          'projectId': projectId,
          'workspaceId': workspaceId,
          'userLocalTime': DateTime.now().toIso8601String(),
        },
      );
      AppLogger.debug('Success: $op', tag: 'AiTaskRemoteDataSource');
      return ParsedTaskDraftDto.fromJson(response.data!);
    } on DioException catch (e) {
      AppLogger.error('Failed: $op', error: e, tag: 'AiTaskRemoteDataSource');
      throw DioErrorHandler.handle(e);
    }
  }
}
