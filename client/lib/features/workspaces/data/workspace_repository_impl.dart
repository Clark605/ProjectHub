import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

@LazySingleton(as: WorkspaceRepository)
class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final Dio _dio;

  WorkspaceRepositoryImpl(this._dio);

  @override
  Future<List<WorkspaceDto>> getWorkspaces() async {
    try {
      final response = await _dio.get(ApiConstants.workspaces);
      final list = response.data as List<dynamic>;
      return list
          .map((item) => WorkspaceDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<WorkspaceDto> getWorkspace(int id) async {
    try {
      final response = await _dio.get(ApiConstants.workspaceById(id));
      return WorkspaceDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.workspaces,
        data: request.toJson(),
      );
      return WorkspaceDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
