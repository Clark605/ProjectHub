import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/projects/cubit/project_detail_cubit.dart';
import 'package:client/features/projects/cubit/project_detail_state.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const UpdateProjectRequest(name: 'Fallback'));
  });

  group('ProjectDetailCubit', () {
    late MockProjectRepository repository;

    const initialProject = ProjectDto(
      id: 50,
      workspaceId: 10,
      name: 'Alpha Project',
      description: 'Alpha Desc',
      status: 'Planning',
      createdBy: 'creator_1',
    );

    setUp(() {
      repository = MockProjectRepository();
    });

    test('initial state is initial', () {
      final cubit = ProjectDetailCubit(repository);
      expect(cubit.state, const ProjectDetailState.initial());
      cubit.close();
    });

    blocTest<ProjectDetailCubit, ProjectDetailState>(
      'loadProject emits loading then loaded on success',
      build: () {
        when(
          () => repository.getProject(
            50,
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer((_) async => initialProject);
        return ProjectDetailCubit(repository);
      },
      act: (cubit) => cubit.loadProject(50),
      expect: () => [
        const ProjectDetailState.loading(),
        const ProjectDetailState.loaded(project: initialProject),
      ],
      verify: (_) {
        verify(() => repository.getProject(50, forceRefresh: false)).called(1);
      },
    );

    blocTest<ProjectDetailCubit, ProjectDetailState>(
      'loadProject handles error via SafeActionCubit',
      build: () {
        when(
          () => repository.getProject(
            50,
            forceRefresh: any(named: 'forceRefresh'),
          ),
        ).thenAnswer(
          (_) async =>
              throw const ServerException(message: 'Project not found'),
        );
        return ProjectDetailCubit(repository);
      },
      act: (cubit) => cubit.loadProject(50),
      expect: () => [
        const ProjectDetailState.loading(),
        const ProjectDetailState.error('Project not found'),
      ],
    );

    blocTest<ProjectDetailCubit, ProjectDetailState>(
      'updateProject updates project data and sets success message',
      build: () {
        when(() => repository.updateProject(50, any())).thenAnswer(
          (_) async => initialProject.copyWith(
            name: 'Renamed Project',
            description: 'Updated Desc',
            status: 'Active',
          ),
        );
        return ProjectDetailCubit(repository);
      },
      seed: () => const ProjectDetailState.loaded(project: initialProject),
      act: (cubit) => cubit.updateProject(
        const UpdateProjectRequest(
          name: 'Renamed Project',
          description: 'Updated Desc',
          status: 'Active',
        ),
      ),
      expect: () => [
        isA<ProjectDetailLoaded>().having((s) => s.isSaving, 'isSaving', true),
        isA<ProjectDetailLoaded>()
            .having((s) => s.project.name, 'name', 'Renamed Project')
            .having((s) => s.project.status, 'status', 'Active')
            .having((s) => s.isSaving, 'isSaving', false)
            .having(
              (s) => s.actionSuccessMessage,
              'actionSuccessMessage',
              'projectUpdated',
            ),
      ],
      verify: (_) {
        verify(
          () => repository.updateProject(
            50,
            const UpdateProjectRequest(
              name: 'Renamed Project',
              description: 'Updated Desc',
              status: 'Active',
            ),
          ),
        ).called(1);
      },
    );

    blocTest<ProjectDetailCubit, ProjectDetailState>(
      'deleteProject emits deleted state on success',
      build: () {
        when(() => repository.deleteProject(50)).thenAnswer((_) async {});
        return ProjectDetailCubit(repository);
      },
      seed: () => const ProjectDetailState.loaded(project: initialProject),
      act: (cubit) => cubit.deleteProject(),
      expect: () => [
        isA<ProjectDetailLoaded>().having(
          (s) => s.isDeleting,
          'isDeleting',
          true,
        ),
        const ProjectDetailState.deleted(),
      ],
      verify: (_) {
        verify(() => repository.deleteProject(50)).called(1);
      },
    );
  });
}
