import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/projects/cubit/project_detail_cubit.dart';
import 'package:client/features/projects/cubit/project_detail_state.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';

class _FakeProjectRepo implements ProjectRepository {
  ProjectDto? project;
  bool shouldThrow = false;
  String errorMessage = 'Failed';

  @override
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  }) async => [];

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async {
    if (shouldThrow) {
      throw ServerException(message: errorMessage);
    }
    return project!;
  }

  @override
  Future<ProjectDto> createProject(
    int workspaceId,
    CreateProjectRequest request,
  ) async => project!;

  @override
  Future<ProjectDto> updateProject(int id, UpdateProjectRequest request) async {
    if (shouldThrow) {
      throw ValidationException(message: errorMessage);
    }
    project = project!.copyWith(
      name: request.name,
      description: request.description,
      status: request.status,
    );
    return project!;
  }

  @override
  Future<void> deleteProject(int id) async {
    if (shouldThrow) {
      throw ServerException(message: errorMessage);
    }
    project = null;
  }

  @override
  void clearCache([int? workspaceId]) {}

  @override
  bool hasCachedProjects(int workspaceId) => false;

  @override
  bool hasCachedProject(int id) => false;
}

void main() {
  group('ProjectDetailCubit', () {
    late _FakeProjectRepo repository;
    late ProjectDetailCubit cubit;

    const initialProject = ProjectDto(
      id: 50,
      workspaceId: 10,
      name: 'Alpha Project',
      description: 'Alpha Desc',
      status: 'Planning',
      createdBy: 'creator_1',
    );

    setUp(() {
      repository = _FakeProjectRepo()..project = initialProject;
      cubit = ProjectDetailCubit(repository);
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is initial', () {
      expect(cubit.state, const ProjectDetailState.initial());
    });

    test('loadProject emits loading then loaded on success', () async {
      await cubit.loadProject(50);
      expect(cubit.state is ProjectDetailLoaded, isTrue);
      final loaded = cubit.state as ProjectDetailLoaded;
      expect(loaded.project.name, 'Alpha Project');
      expect(loaded.isSaving, isFalse);
      expect(loaded.isDeleting, isFalse);
    });

    test('loadProject handles error via SafeActionCubit', () async {
      repository.shouldThrow = true;
      repository.errorMessage = 'Project not found';

      await cubit.loadProject(50);
      expect(cubit.state, const ProjectDetailState.error('Project not found'));
    });

    test(
      'updateProject updates project data and sets success message',
      () async {
        await cubit.loadProject(50);

        await cubit.updateProject(
          const UpdateProjectRequest(
            name: 'Renamed Project',
            description: 'Updated Desc',
            status: 'Active',
          ),
        );

        final loaded = cubit.state as ProjectDetailLoaded;
        expect(loaded.project.name, 'Renamed Project');
        expect(loaded.project.status, 'Active');
        expect(loaded.actionSuccessMessage, isNotNull);
      },
    );

    test('deleteProject emits deleted state on success', () async {
      await cubit.loadProject(50);
      await cubit.deleteProject();
      expect(cubit.state, const ProjectDetailState.deleted());
    });
  });
}
