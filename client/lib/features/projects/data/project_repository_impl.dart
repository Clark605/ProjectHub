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
    AppLogger.debug(wsId != null ? 'Clearing cache for ws $wsId' : 'Clearing all project caches', tag: 'ProjectRepository');
    if (wsId != null) {
      _wsProjectsCache.remove(wsId);
      _projectDetailCache.removeWhere((_, p) => p.workspaceId == wsId);
    } else {
      _wsProjectsCache.clear();
      _projectDetailCache.clear();
    }
  }

  @override
  Future<List<ProjectDto>> getProjects(int wsId, {String? status, bool forceRefresh = false}) async {
    final hasStatus = status != null && status.isNotEmpty && status.toLowerCase() != 'all';
    if (!forceRefresh && _wsProjectsCache.containsKey(wsId)) {
      AppLogger.debug('Cache hit for ws $wsId projects', tag: 'ProjectRepository');
      final cached = _wsProjectsCache[wsId]!;
      return hasStatus ? cached.where((p) => p.status.toLowerCase() == status.toLowerCase()).toList() : cached;
    }

    try {
      AppLogger.info('Fetching projects for ws $wsId', tag: 'ProjectRepository');
      final qParams = hasStatus ? {'status': status} : null;
      final res = await _dio.get(ApiConstants.workspaceProjects(wsId), queryParameters: qParams);
      final list = (res.data as List).map((i) => ProjectDto.fromJson(i as Map<String, dynamic>)).toList();
      
      for (final p in list) { _projectDetailCache[p.id] = p; }
      if (!hasStatus) _wsProjectsCache[wsId] = list;
      
      AppLogger.debug('Fetched ${list.length} projects for ws $wsId', tag: 'ProjectRepository');
      return list;
    } on DioException catch (e) {
      AppLogger.error('Failed to fetch projects for ws $wsId', error: e, tag: 'ProjectRepository');
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async {
    if (!forceRefresh && _projectDetailCache.containsKey(id)) {
      AppLogger.debug('Cache hit for project $id detail', tag: 'ProjectRepository');
      return _projectDetailCache[id]!;
    }
    try {
      AppLogger.info('Fetching project $id detail', tag: 'ProjectRepository');
      final project = ProjectDto.fromJson((await _dio.get(ApiConstants.projectById(id))).data as Map<String, dynamic>);
      _projectDetailCache[id] = project;
      
      if (_wsProjectsCache.containsKey(project.workspaceId)) {
        final list = _wsProjectsCache[project.workspaceId]!;
        final idx = list.indexWhere((p) => p.id == id);
        if (idx != -1) list[idx] = project; else list.add(project);
      }
      
      AppLogger.debug('Fetched project $id', tag: 'ProjectRepository');
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
      final created = ProjectDto.fromJson((await _dio.post(ApiConstants.workspaceProjects(wsId), data: req.toJson())).data as Map<String, dynamic>);
      _projectDetailCache[created.id] = created;
      if (_wsProjectsCache.containsKey(wsId)) {
        _wsProjectsCache[wsId] = [created, ..._wsProjectsCache[wsId]!];
      }
      AppLogger.debug('Created project ${created.id}', tag: 'ProjectRepository');
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
      final updated = ProjectDto.fromJson((await _dio.put(ApiConstants.projectById(id), data: req.toJson())).data as Map<String, dynamic>);
      _projectDetailCache[id] = updated;
      if (_wsProjectsCache.containsKey(updated.workspaceId)) {
        _wsProjectsCache[updated.workspaceId] = _wsProjectsCache[updated.workspaceId]!.map((p) => p.id == id ? updated : p).toList();
      }
      AppLogger.debug('Updated project $id', tag: 'ProjectRepository');
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
        for (final list in _wsProjectsCache.values) { list.removeWhere((p) => p.id == id); }
      }
      AppLogger.debug('Deleted project $id', tag: 'ProjectRepository');
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
