import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_state.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';

class _FakeProjectRepo implements ProjectRepository {
  List<ProjectDto> projects = [];
  bool shouldThrow = false;
  String errorMessage = 'Error loading projects';

  @override
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  }) async {
    if (shouldThrow) {
      throw ServerException(message: errorMessage);
    }
    return List.of(projects);
  }

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async {
    return projects.firstWhere((p) => p.id == id);
  }

  @override
  Future<ProjectDto> createProject(
    int workspaceId,
    CreateProjectRequest request,
  ) async {
    if (shouldThrow) {
      throw ServerException(message: errorMessage);
    }
    final newProj = ProjectDto(
      id: 99,
      workspaceId: workspaceId,
      name: request.name,
      description: request.description,
      status: 'Planning',
    );
    projects.add(newProj);
    return newProj;
  }

  @override
  Future<ProjectDto> updateProject(int id, UpdateProjectRequest request) async {
    return projects.firstWhere((p) => p.id == id);
  }

  @override
  Future<void> deleteProject(int id) async {
    projects.removeWhere((p) => p.id == id);
  }

  @override
  void clearCache([int? workspaceId]) {}

  @override
  bool hasCachedProjects(int workspaceId) => false;

  @override
  bool hasCachedProject(int id) => false;
}

void main() {
  group('ProjectsListCubit', () {
    late _FakeProjectRepo repository;
    late ProjectsListCubit cubit;

    final testProjects = [
      const ProjectDto(
        id: 1,
        workspaceId: 10,
        name: 'Project 1',
        description: 'Desc 1',
        status: 'Planning',
      ),
      const ProjectDto(
        id: 2,
        workspaceId: 10,
        name: 'Project 2',
        description: 'Desc 2',
        status: 'Active',
      ),
      const ProjectDto(
        id: 3,
        workspaceId: 10,
        name: 'Project 3',
        description: 'Desc 3',
        status: 'Completed',
      ),
    ];

    setUp(() {
      repository = _FakeProjectRepo();
      cubit = ProjectsListCubit(repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is initial', () {
      expect(cubit.state, const ProjectsListState.initial());
    });

    test('loadProjects emits empty when 0 projects returned', () async {
      repository.projects = [];
      await cubit.loadProjects(10);
      expect(cubit.state, const ProjectsListState.empty(selectedFilter: 'All'));
    });

    test('loadProjects emits loaded with filtered and all projects', () async {
      repository.projects = List.from(testProjects);
      await cubit.loadProjects(10);

      expect(cubit.state is ProjectsListLoaded, isTrue);
      final loaded = cubit.state as ProjectsListLoaded;
      expect(loaded.projects.length, 3);
      expect(loaded.allProjects.length, 3);
      expect(loaded.selectedFilter, 'All');
    });

    test('filterByStatus filters projects in memory', () async {
      repository.projects = List.from(testProjects);
      await cubit.loadProjects(10);

      cubit.filterByStatus('Active');
      final loaded = cubit.state as ProjectsListLoaded;
      expect(loaded.selectedFilter, 'Active');
      expect(loaded.projects.length, 1);
      expect(loaded.projects.first.name, 'Project 2');

      cubit.filterByStatus('All');
      final allLoaded = cubit.state as ProjectsListLoaded;
      expect(allLoaded.projects.length, 3);
    });

    test(
      'loadProjects handles errors gracefully via SafeActionCubit',
      () async {
        repository.shouldThrow = true;
        repository.errorMessage = 'Database down';

        await cubit.loadProjects(10);
        expect(cubit.state, const ProjectsListState.error('Database down'));
      },
    );

    test('createProject adds new project to state', () async {
      repository.projects = List.from(testProjects);
      await cubit.loadProjects(10);

      final created = await cubit.createProject(
        const CreateProjectRequest(
          name: 'Brand New Project',
          description: 'Desc',
        ),
      );

      expect(created, isNotNull);
      expect(created!.name, 'Brand New Project');
      final loaded = cubit.state as ProjectsListLoaded;
      expect(loaded.allProjects.length, 4);
    });
  });
}
