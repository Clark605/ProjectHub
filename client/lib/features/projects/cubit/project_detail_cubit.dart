import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/projects/cubit/project_detail_state.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';

@injectable
class ProjectDetailCubit extends SafeActionCubit<ProjectDetailState> {
  final ProjectRepository _projectRepository;

  ProjectDetailCubit(this._projectRepository)
    : super(const ProjectDetailState.initial());

  Future<void> loadProject(int id, {bool forceRefresh = false}) async {
    emit(const ProjectDetailState.loading());
    await safeExecute(
      () async {
        final project = await _projectRepository.getProject(
          id,
          forceRefresh: forceRefresh,
        );
        emit(ProjectDetailState.loaded(project: project));
      },
      onFailure: (failure) => emit(ProjectDetailState.error(failure)),
      logTag: 'ProjectDetailCubit',
    );
  }

  Future<ProjectDto?> updateProject(UpdateProjectRequest request) async {
    final currentState = state;
    if (currentState is! ProjectDetailLoaded) return null;

    emit(
      currentState.copyWith(
        isSaving: true,
        failure: null,
        actionSuccessMessage: null,
      ),
    );

    final updated = await safeExecute<ProjectDto>(
      () async {
        final result = await _projectRepository.updateProject(
          currentState.project.id,
          request,
        );
        emit(
          currentState.copyWith(
            project: result,
            isSaving: false,
            actionSuccessMessage: 'projectUpdated',
          ),
        );
        return result;
      },
      onFailure: (failure) {
        emit(currentState.copyWith(isSaving: false, failure: failure));
      },
      logTag: 'ProjectDetailCubit',
    );

    return updated;
  }

  Future<bool> deleteProject() async {
    final currentState = state;
    if (currentState is! ProjectDetailLoaded) return false;

    emit(
      currentState.copyWith(
        isDeleting: true,
        failure: null,
        actionSuccessMessage: null,
      ),
    );

    final success = await safeExecute<bool>(
      () async {
        await _projectRepository.deleteProject(currentState.project.id);
        emit(const ProjectDetailState.deleted());
        return true;
      },
      onFailure: (failure) {
        emit(currentState.copyWith(isDeleting: false, failure: failure));
      },
      logTag: 'ProjectDetailCubit',
    );

    return success ?? false;
  }

  void clearError() {
    final currentState = state;
    if (currentState is ProjectDetailLoaded) {
      emit(currentState.copyWith(failure: null));
    }
  }

  void clearMessages() {
    final currentState = state;
    if (currentState is ProjectDetailLoaded) {
      emit(currentState.copyWith(failure: null, actionSuccessMessage: null));
    }
  }
}
