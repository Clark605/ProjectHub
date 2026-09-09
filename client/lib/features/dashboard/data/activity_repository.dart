import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';

abstract class ActivityRepository {
  Future<List<ActivityEventDto>> getWorkspaceActivities(int workspaceId, {int limit = 20});
  Future<List<ActivityEventDto>> getProjectActivities(int projectId, {int limit = 50});
}

@LazySingleton(as: ActivityRepository)
class ActivityRepositoryImpl implements ActivityRepository {
  final Dio _dio;

  ActivityRepositoryImpl(this._dio);

  @override
  Future<List<ActivityEventDto>> getWorkspaceActivities(int workspaceId, {int limit = 20}) async {
    try {
      final response = await _dio.get(ApiConstants.workspaceActivity(workspaceId, limit: limit));
      final list = response.data as List<dynamic>;
      return list.map((e) => ActivityEventDto.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch workspace activities (workspaceId: $workspaceId, status: ${e.response?.statusCode})',
        tag: 'ActivityRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error fetching workspace activities (workspaceId: $workspaceId)',
        tag: 'ActivityRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<List<ActivityEventDto>> getProjectActivities(int projectId, {int limit = 50}) async {
    try {
      final response = await _dio.get(ApiConstants.projectActivity(projectId, limit: limit));
      final list = response.data as List<dynamic>;
      return list.map((e) => ActivityEventDto.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e, stackTrace) {
      AppLogger.error(
        'Failed to fetch project activities (projectId: $projectId, status: ${e.response?.statusCode})',
        tag: 'ActivityRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    } catch (e, stackTrace) {
      AppLogger.error(
        'Unexpected error fetching project activities (projectId: $projectId)',
        tag: 'ActivityRepository',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
}
