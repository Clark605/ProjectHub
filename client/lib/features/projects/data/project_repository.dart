import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/project_status.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';

abstract class ProjectRepository {
  /// Fetches projects for a given workspace, optionally filtered by status.
  /// If [forceRefresh] is false, returns cached results when available.
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  });

  /// Fetches single project detail by ID.
  /// If [forceRefresh] is false, returns cached project when available.
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false});

  /// Creates a new project in the specified workspace.
  Future<ProjectDto> createProject(
    int workspaceId,
    CreateProjectRequest request,
  );

  /// Updates existing project metadata.
  Future<ProjectDto> updateProject(int id, UpdateProjectRequest request);

  /// Deletes project by ID.
  Future<void> deleteProject(int id);

  /// Clears in-memory cache for a specific workspace or entirely.
  void clearCache([int? workspaceId]);

  /// Returns whether projects for the given workspace are cached in memory.
  bool hasCachedProjects(int workspaceId);

  /// Returns whether detail for the given project ID is cached in memory.
  bool hasCachedProject(int id);
}

/// Extension providing business-level filtering on [ProjectRepository].
extension ProjectFiltering on ProjectRepository {
  List<ProjectDto> filterProjects(List<ProjectDto> projects, String status) {
    if (status.isEmpty || status.toLowerCase() == 'all') return projects;
    final target = ProjectStatus.fromString(status);
    return projects.where((p) => p.statusEnum == target).toList();
  }
}
