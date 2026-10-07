import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_state.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(
      const CreateProjectRequest(name: 'Test Project'),
    );
  });

  group('ProjectsListCubit', () {
    late MockProjectRepository repository;

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
      repository = MockProjectRepository();
    });

    test('initial state is initial', () {
      final cubit = ProjectsListCubit(repository);
      expect(cubit.state, const ProjectsListState.initial());
      cubit.close();
    });

    blocTest<ProjectsListCubit, ProjectsListState>(
      'loadProjects emits empty when 0 projects returned',
      build: () {
        when(
          () => repository.getProjects(10, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => []);
        return ProjectsListCubit(repository);
      },
      act: (cubit) => cubit.loadProjects(10),
      expect: () => [
        const ProjectsListState.loading(),
        const ProjectsListState.empty(selectedFilter: 'All'),
      ],
      verify: (_) {
        verify(
          () => repository.getProjects(10, forceRefresh: false),
        ).called(1);
      },
    );

    blocTest<ProjectsListCubit, ProjectsListState>(
      'loadProjects emits loaded with filtered and all projects',
      build: () {
        when(
          () => repository.getProjects(10, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => testProjects);
        return ProjectsListCubit(repository);
      },
      act: (cubit) => cubit.loadProjects(10),
      expect: () => [
        const ProjectsListState.loading(),
        ProjectsListState.loaded(
          projects: testProjects,
          allProjects: testProjects,
          selectedFilter: 'All',
        ),
      ],
    );

    blocTest<ProjectsListCubit, ProjectsListState>(
      'filterByStatus filters projects in memory',
      build: () {
        when(
          () => repository.getProjects(10, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => testProjects);
        return ProjectsListCubit(repository);
      },
      act: (cubit) async {
        await cubit.loadProjects(10);
        cubit.filterByStatus('Active');
        cubit.filterByStatus('All');
      },
      skip: 2, // skip loading and initial loaded
      expect: () => [
        isA<ProjectsListLoaded>()
            .having((s) => s.selectedFilter, 'filter', 'Active')
            .having((s) => s.projects.length, 'projects length', 1)
            .having((s) => s.projects.first.name, 'project name', 'Project 2'),
        isA<ProjectsListLoaded>()
            .having((s) => s.selectedFilter, 'filter', 'All')
            .having((s) => s.projects.length, 'projects length', 3),
      ],
    );

    blocTest<ProjectsListCubit, ProjectsListState>(
      'loadProjects handles errors gracefully via SafeActionCubit',
      build: () {
        when(
          () => repository.getProjects(10, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => throw const ServerException(message: 'Database down'));
        return ProjectsListCubit(repository);
      },
      act: (cubit) => cubit.loadProjects(10),
      expect: () => [
        const ProjectsListState.loading(),
        const ProjectsListState.error('Database down'),
      ],
    );

    blocTest<ProjectsListCubit, ProjectsListState>(
      'createProject adds new project to state',
      build: () {
        when(
          () => repository.getProjects(10, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => testProjects);
        when(
          () => repository.createProject(10, any()),
        ).thenAnswer(
          (_) async => const ProjectDto(
            id: 99,
            workspaceId: 10,
            name: 'Brand New Project',
            description: 'Desc',
            status: 'Planning',
          ),
        );
        return ProjectsListCubit(repository);
      },
      act: (cubit) async {
        await cubit.loadProjects(10);
        await cubit.createProject(
          const CreateProjectRequest(
            name: 'Brand New Project',
            description: 'Desc',
          ),
        );
      },
      skip: 2, // skip loadProjects loading and loaded
      expect: () => [
        const ProjectsListState.loading(),
        isA<ProjectsListLoaded>()
            .having((s) => s.allProjects.length, 'allProjects length', 4)
            .having(
              (s) => s.allProjects.first.name,
              'new project first',
              'Brand New Project',
            ),
      ],
      verify: (_) {
        verify(
          () => repository.createProject(
            10,
            const CreateProjectRequest(
              name: 'Brand New Project',
              description: 'Desc',
            ),
          ),
        ).called(1);
      },
    );
  });
}
