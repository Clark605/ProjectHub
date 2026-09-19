import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';

@LazySingleton(as: ProjectRepository)
class ProjectRepositoryImpl implements ProjectRepository {
  final Dio _dio;
  final Map<int, List<ProjectDto>> _wsProjectsCache = {};
  final Map<int, ProjectDto> _projectDetailCache = {};

  ProjectRepositoryImpl(this._dio);

  @override
  void clearCache([int? wsId]) {
    AppLogger.debug(
      wsId != null ? 'Clearing cache for ws $wsId' : 'Clearing all project caches',
      tag: 'ProjectRepository',
    );
    if (wsId != null) {
      _wsProjectsCache.remove(wsId);
      _projectDetailCache.removeWhere((_, p) => p.workspaceId == wsId);
    } else {
      _wsProjectsCache.clear();
      _projectDetailCache.clear();
    }
  }

  @override
  Future<List<ProjectDto>> getProjects(
    int wsId, {
    String? status,
    bool forceRefresh = false,
  }) async {
    final hasStatus = status != null && status.isNotEmpty && status.toLowerCase() != 'all';
    if (!forceRefresh && _wsProjectsCache.containsKey(wsId)) {
      AppLogger.debug('Cache hit for ws $wsId projects', tag: 'ProjectRepository');
      return hasStatus ? filterProjects(_wsProjectsCache[wsId]!, status) : _wsProjectsCache[wsId]!;
    }

    try {
      AppLogger.info('Fetching projects for ws $wsId', tag: 'ProjectRepository');
      final res = await _dio.get(
        ApiConstants.workspaceProjects(wsId),
        queryParameters: hasStatus ? {'status': status} : null,
      );
      final list = (res.data as List)
          .map((i) => ProjectDto.fromJson(i as Map<String, dynamic>))
          .toList();

      for (final p in list) {
        _projectDetailCache[p.id] = p;
      }
      if (!hasStatus) _wsProjectsCache[wsId] = list;
      return list;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch projects for ws $wsId', error: e, tag: 'ProjectRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh && _projectDetailCache.containsKey(id)) {
      return _projectDetailCache[id]!;
    }
    try {
      AppLogger.info('Fetching project $id detail', tag: 'ProjectRepository');
      final project = ProjectDto.fromJson(
        (await _dio.get(ApiConstants.projectById(id))).data as Map<String, dynamic>,
      );
      _projectDetailCache[id] = project;

      final wsList = _wsProjectsCache[project.workspaceId];
      if (wsList != null) {
        final idx = wsList.indexWhere((p) => p.id == id);
        if (idx != -1) {
          wsList[idx] = project;
        } else {
          wsList.add(project);
        }
      }
      return project;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch project $id', error: e, tag: 'ProjectRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<ProjectDto> createProject(int wsId, CreateProjectRequest req) async {
    try {
      AppLogger.info('Creating project in ws $wsId', tag: 'ProjectRepository');
      final created = ProjectDto.fromJson(
        (await _dio.post(ApiConstants.workspaceProjects(wsId), data: req.toJson())).data
            as Map<String, dynamic>,
      );
      _projectDetailCache[created.id] = created;
      if (_wsProjectsCache.containsKey(wsId)) {
        _wsProjectsCache[wsId] = [created, ..._wsProjectsCache[wsId]!];
      }
      return created;
    } on DioException catch (e) {
      AppLogger.error('Failed to create project in ws $wsId', error: e, tag: 'ProjectRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<ProjectDto> updateProject(int id, UpdateProjectRequest req) async {
    try {
      AppLogger.info('Updating project $id', tag: 'ProjectRepository');
      final updated = ProjectDto.fromJson(
        (await _dio.put(ApiConstants.projectById(id), data: req.toJson())).data
            as Map<String, dynamic>,
      );
      _projectDetailCache[id] = updated;
      final wsList = _wsProjectsCache[updated.workspaceId];
      if (wsList != null) {
        final idx = wsList.indexWhere((p) => p.id == id);
        if (idx != -1) wsList[idx] = updated;
      }
      return updated;
    } on DioException catch (e) {
      AppLogger.error('Failed to update project $id', error: e, tag: 'ProjectRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    try {
      AppLogger.info('Deleting project $id', tag: 'ProjectRepository');
      await _dio.delete(ApiConstants.projectById(id));
      final cached = _projectDetailCache.remove(id);
      if (cached != null) {
        _wsProjectsCache[cached.workspaceId]?.removeWhere((p) => p.id == id);
      } else {
        for (final list in _wsProjectsCache.values) {
          list.removeWhere((p) => p.id == id);
        }
      }
    } on DioException catch (e) {
      AppLogger.error('Failed to delete project $id', error: e, tag: 'ProjectRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  bool hasCachedProjects(int wsId) => _wsProjectsCache.containsKey(wsId);

  @override
  bool hasCachedProject(int id) => _projectDetailCache.containsKey(id);
}
