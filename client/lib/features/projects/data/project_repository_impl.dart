import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';

@LazySingleton(as: ProjectRepository)
class ProjectRepositoryImpl implements ProjectRepository {
  final Dio _dio;

  // In-memory caching
  final Map<int, List<ProjectDto>> _workspaceProjectsCache = {};
  final Map<int, ProjectDto> _projectDetailCache = {};

  ProjectRepositoryImpl(this._dio);

  @override
  void clearCache([int? workspaceId]) {
    if (workspaceId != null) {
      _workspaceProjectsCache.remove(workspaceId);
      _projectDetailCache.removeWhere((_, p) => p.workspaceId == workspaceId);
    } else {
      _workspaceProjectsCache.clear();
      _projectDetailCache.clear();
    }
  }

  @override
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  }) async {
    final hasStatus =
        status != null && status.isNotEmpty && status.toLowerCase() != 'all';

    if (!forceRefresh && _workspaceProjectsCache.containsKey(workspaceId)) {
      final cached = _workspaceProjectsCache[workspaceId]!;
      if (hasStatus) {
        return cached
            .where((p) => p.status.toLowerCase() == status.toLowerCase())
            .toList();
      }
      return cached;
    }

    try {
      final queryParams = <String, dynamic>{};
      if (hasStatus) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        ApiConstants.workspaceProjects(workspaceId),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final list = (response.data as List<dynamic>)
          .map((item) => ProjectDto.fromJson(item as Map<String, dynamic>))
          .toList();

      for (final project in list) {
        _projectDetailCache[project.id] = project;
      }

      if (!hasStatus) {
        _workspaceProjectsCache[workspaceId] = list;
      }

      return list;
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh && _projectDetailCache.containsKey(id)) {
      return _projectDetailCache[id]!;
    }

    try {
      final response = await _dio.get(ApiConstants.projectById(id));
      final project = ProjectDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      _projectDetailCache[id] = project;

      // Update workspace cache if present
      if (_workspaceProjectsCache.containsKey(project.workspaceId)) {
        final list = _workspaceProjectsCache[project.workspaceId]!;
        final index = list.indexWhere((p) => p.id == id);
        if (index != -1) {
          list[index] = project;
        } else {
          list.add(project);
        }
      }

      return project;
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<ProjectDto> createProject(
    int workspaceId,
    CreateProjectRequest request,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.workspaceProjects(workspaceId),
        data: request.toJson(),
      );

      final created = ProjectDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      _projectDetailCache[created.id] = created;

      if (_workspaceProjectsCache.containsKey(workspaceId)) {
        _workspaceProjectsCache[workspaceId] = [
          created,
          ..._workspaceProjectsCache[workspaceId]!,
        ];
      }

      return created;
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<ProjectDto> updateProject(int id, UpdateProjectRequest request) async {
    try {
      final response = await _dio.put(
        ApiConstants.projectById(id),
        data: request.toJson(),
      );

      final updated = ProjectDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      _projectDetailCache[id] = updated;

      if (_workspaceProjectsCache.containsKey(updated.workspaceId)) {
        _workspaceProjectsCache[updated.workspaceId] =
            _workspaceProjectsCache[updated.workspaceId]!
                .map((p) => p.id == id ? updated : p)
                .toList();
      }

      return updated;
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    try {
      await _dio.delete(ApiConstants.projectById(id));

      final cached = _projectDetailCache.remove(id);
      if (cached != null) {
        _workspaceProjectsCache[cached.workspaceId]?.removeWhere(
          (p) => p.id == id,
        );
      } else {
        for (final list in _workspaceProjectsCache.values) {
          list.removeWhere((p) => p.id == id);
        }
      }
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  bool hasCachedProjects(int workspaceId) =>
      _workspaceProjectsCache.containsKey(workspaceId);

  @override
  bool hasCachedProject(int id) => _projectDetailCache.containsKey(id);
}
