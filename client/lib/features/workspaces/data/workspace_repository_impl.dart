import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_members_mixin.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

@LazySingleton(as: WorkspaceRepository)
class WorkspaceRepositoryImpl
    with WorkspaceMembersMixin
    implements WorkspaceRepository {
  @override
  final Dio dio;

  final Map<int, WorkspaceDto> _workspaceCache = {};
  WorkspaceDto? _activeWorkspace;
  final _activeWorkspaceController =
      StreamController<WorkspaceDto?>.broadcast();

  WorkspaceRepositoryImpl(this.dio);

  @override
  Stream<WorkspaceDto?> get activeWorkspaceChanges =>
      _activeWorkspaceController.stream;

  @override
  WorkspaceDto? get activeWorkspace => _activeWorkspace;

  @override
  void setActiveWorkspace(WorkspaceDto? workspace) {
    _activeWorkspace = workspace;
    _activeWorkspaceController.add(workspace);
  }

  @override
  bool hasCachedSettings(int workspaceId) {
    return _workspaceCache.containsKey(workspaceId) &&
        membersCache.containsKey(workspaceId);
  }

  @override
  void clearCache([int? workspaceId]) {
    if (workspaceId != null) {
      _workspaceCache.remove(workspaceId);
      membersCache.remove(workspaceId);
      AppLogger.debug(
        'Cache cleared for workspace $workspaceId',
        tag: 'WorkspaceRepository',
      );
    } else {
      _workspaceCache.clear();
      membersCache.clear();
      AppLogger.debug('Entire cache cleared', tag: 'WorkspaceRepository');
    }
  }

  @override
  Future<List<WorkspaceDto>> getWorkspaces() async {
    AppLogger.debug('Fetching workspaces', tag: 'WorkspaceRepository');
    try {
      final response = await dio.get(ApiConstants.workspaces);
      final list = response.data as List<dynamic>;
      return list
          .map((item) => WorkspaceDto.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to fetch workspaces: ${e.message}',
        tag: 'WorkspaceRepository',
      );
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
      final response = await dio.get(ApiConstants.workspaceById(id));
      final workspace = WorkspaceDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      _workspaceCache[id] = workspace;
      return workspace;
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to fetch workspace $id: ${e.message}',
        tag: 'WorkspaceRepository',
      );
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request) async {
    AppLogger.info(
      'Creating workspace: ${request.name}',
      tag: 'WorkspaceRepository',
    );
    try {
      final response = await dio.post(
        ApiConstants.workspaces,
        data: request.toJson(),
      );
      final created = WorkspaceDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      _workspaceCache[created.id] = created;
      return created;
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to create workspace: ${e.message}',
        tag: 'WorkspaceRepository',
      );
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
      final response = await dio.put(
        ApiConstants.workspaceById(id),
        data: request.toJson(),
      );
      final updated = WorkspaceDto.fromJson(
        response.data as Map<String, dynamic>,
      );
      _workspaceCache[id] = updated;
      if (_activeWorkspace?.id == id) {
        setActiveWorkspace(updated);
      }
      return updated;
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to update workspace $id: ${e.message}',
        tag: 'WorkspaceRepository',
      );
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteWorkspace(int id) async {
    AppLogger.info('Deleting workspace $id', tag: 'WorkspaceRepository');
    try {
      await dio.delete(ApiConstants.workspaceById(id));
      _workspaceCache.remove(id);
      membersCache.remove(id);
      if (_activeWorkspace?.id == id) {
        setActiveWorkspace(null);
      }
    } on DioException catch (e) {
      AppLogger.error(
        'Failed to delete workspace $id: ${e.message}',
        tag: 'WorkspaceRepository',
      );
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  @disposeMethod
  void dispose() {
    _activeWorkspaceController.close();
  }
}
