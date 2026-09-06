import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

@LazySingleton(as: WorkspaceRepository)
class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final Dio _dio;
  final Map<int, WorkspaceDto> _workspaceCache = {};
  final Map<int, List<MemberDto>> _membersCache = {};

  WorkspaceRepositoryImpl(this._dio);

  @override
  bool hasCachedSettings(int workspaceId) {
    return _workspaceCache.containsKey(workspaceId) &&
        _membersCache.containsKey(workspaceId);
  }

  @override
  void clearCache([int? workspaceId]) {
    if (workspaceId != null) {
      _workspaceCache.remove(workspaceId);
      _membersCache.remove(workspaceId);
      AppLogger.debug('Cache cleared for workspace $workspaceId', tag: 'WorkspaceRepository');
    } else {
      _workspaceCache.clear();
      _membersCache.clear();
      AppLogger.debug('Entire cache cleared', tag: 'WorkspaceRepository');
    }
  }

  @override
  Future<List<WorkspaceDto>> getWorkspaces() async {
    AppLogger.debug('Fetching workspaces', tag: 'WorkspaceRepository');
    try {
      final response = await _dio.get(ApiConstants.workspaces);
      final list = response.data as List<dynamic>;
      return list
          .map((item) => WorkspaceDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch workspaces: ${e.message}', tag: 'WorkspaceRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<WorkspaceDto> getWorkspace(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh && _workspaceCache.containsKey(id)) {
      return _workspaceCache[id]!;
    }
    AppLogger.debug('Fetching workspace $id', tag: 'WorkspaceRepository');
    try {
      final response = await _dio.get(ApiConstants.workspaceById(id));
      final workspace = WorkspaceDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      _workspaceCache[id] = workspace;
      return workspace;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch workspace $id: ${e.message}', tag: 'WorkspaceRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request) async {
    AppLogger.info('Creating workspace: ${request.name}', tag: 'WorkspaceRepository');
    try {
      final response = await _dio.post(
        ApiConstants.workspaces,
        data: request.toJson(),
      );
      final created = WorkspaceDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      _workspaceCache[created.id] = created;
      return created;
    } on DioException catch (e) {
      AppLogger.error('Failed to create workspace: ${e.message}', tag: 'WorkspaceRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<WorkspaceDto> updateWorkspace(
    int id,
    UpdateWorkspaceRequest request,
  ) async {
    AppLogger.info('Updating workspace $id', tag: 'WorkspaceRepository');
    try {
      final response = await _dio.put(
        ApiConstants.workspaceById(id),
        data: request.toJson(),
      );
      final updated = WorkspaceDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      _workspaceCache[id] = updated;
      return updated;
    } on DioException catch (e) {
      AppLogger.error('Failed to update workspace $id: ${e.message}', tag: 'WorkspaceRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteWorkspace(int id) async {
    AppLogger.info('Deleting workspace $id', tag: 'WorkspaceRepository');
    try {
      await _dio.delete(ApiConstants.workspaceById(id));
      _workspaceCache.remove(id);
      _membersCache.remove(id);
    } on DioException catch (e) {
      AppLogger.error('Failed to delete workspace $id: ${e.message}', tag: 'WorkspaceRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<List<MemberDto>> getMembers(
    int workspaceId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _membersCache.containsKey(workspaceId)) {
      return _membersCache[workspaceId]!;
    }
    AppLogger.debug('Fetching members for workspace $workspaceId', tag: 'WorkspaceRepository');
    try {
      final response = await _dio.get(
        ApiConstants.workspaceMembers(workspaceId),
      );
      final list = response.data as List<dynamic>;
      final members = list
          .map((item) => MemberDto.fromJson(item as Map<String, dynamic>))
          .toList();
      _membersCache[workspaceId] = members;
      return members;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch members for $workspaceId: ${e.message}', tag: 'WorkspaceRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<MemberDto> addMember(int workspaceId, AddMemberRequest request) async {
    AppLogger.info('Adding member ${request.email} to workspace $workspaceId', tag: 'WorkspaceRepository');
    try {
      final response = await _dio.post(
        ApiConstants.workspaceMembers(workspaceId),
        data: request.toJson(),
      );
      final member = MemberDto.fromJson(response.data as Map<String, dynamic>);
      if (_membersCache.containsKey(workspaceId)) {
        _membersCache[workspaceId] = [..._membersCache[workspaceId]!, member];
      }
      return member;
    } on DioException catch (e) {
      AppLogger.error('Failed to add member: ${e.message}', tag: 'WorkspaceRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<void> removeMember(int workspaceId, String userId) async {
    AppLogger.info('Removing member $userId from workspace $workspaceId', tag: 'WorkspaceRepository');
    try {
      await _dio.delete(
        ApiConstants.removeWorkspaceMember(workspaceId, userId),
      );
      if (_membersCache.containsKey(workspaceId)) {
        _membersCache[workspaceId] = _membersCache[workspaceId]!
            .where((m) => m.userId != userId)
            .toList();
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to remove member: ${e.message}', tag: 'WorkspaceRepository');
      throw DioErrorHandler.handle(e);
    }
  }
}