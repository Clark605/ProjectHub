import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

@injectable
class WorkspaceSettingsCubit extends Cubit<WorkspaceSettingsState> {
  final WorkspaceRepository _repository;
  final WorkspaceContextCubit _contextCubit;

  WorkspaceSettingsCubit(this._repository, this._contextCubit)
    : super(const WorkspaceSettingsState.initial());

  Future<void> loadSettings(
    int workspaceId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _repository.hasCachedSettings(workspaceId)) {
      try {
        final cachedWorkspace = await _repository.getWorkspace(workspaceId);
        final cachedMembers = await _repository.getMembers(workspaceId);
        emit(
          WorkspaceSettingsState.loaded(
            workspace: cachedWorkspace,
            members: cachedMembers,
            isRevalidating: true,
          ),
        );

        // Revalidate in background (stale-while-revalidate)
        final freshWorkspace = await _repository.getWorkspace(
          workspaceId,
          forceRefresh: true,
        );
        final freshMembers = await _repository.getMembers(
          workspaceId,
          forceRefresh: true,
        );
        final currentState = state;
        if (currentState is WorkspaceSettingsLoaded) {
          emit(
            currentState.copyWith(
              workspace: freshWorkspace,
              members: freshMembers,
              isRevalidating: false,
            ),
          );
        }
        return;
      } catch (_) {
        final currentState = state;
        if (currentState is WorkspaceSettingsLoaded) {
          emit(currentState.copyWith(isRevalidating: false));
          return;
        }
      }
    }

    emit(const WorkspaceSettingsState.loading());
    try {
      final workspace = await _repository.getWorkspace(
        workspaceId,
        forceRefresh: forceRefresh,
      );
      final members = await _repository.getMembers(
        workspaceId,
        forceRefresh: forceRefresh,
      );
      emit(
        WorkspaceSettingsState.loaded(
          workspace: workspace,
          members: members,
          isRevalidating: false,
        ),
      );
    } on AppException catch (e) {
      emit(WorkspaceSettingsState.error(e.message));
    } catch (_) {
      emit(
        const WorkspaceSettingsState.error('Failed to load workspace settings'),
      );
    }
  }

  Future<bool> updateDetails(String name, String description) async {
    final currentState = state;
    if (currentState is! WorkspaceSettingsLoaded) return false;

    emit(
      currentState.copyWith(
        isSaving: true,
        actionSuccessMessage: null,
        errorMessage: null,
      ),
    );
    try {
      final updated = await _repository.updateWorkspace(
        currentState.workspace.id,
        UpdateWorkspaceRequest(name: name, description: description),
      );
      await _contextCubit.selectWorkspace(updated);

      emit(
        currentState.copyWith(
          workspace: updated,
          isSaving: false,
          actionSuccessMessage: 'detailsUpdated',
        ),
      );
      return true;
    } on AppException catch (e) {
      emit(currentState.copyWith(isSaving: false, errorMessage: e.message));
      return false;
    } catch (_) {
      emit(
        currentState.copyWith(
          isSaving: false,
          errorMessage: 'Failed to update workspace details',
        ),
      );
      return false;
    }
  }

  Future<bool> inviteMember(String email) async {
    final currentState = state;
    if (currentState is! WorkspaceSettingsLoaded) return false;

    emit(
      currentState.copyWith(
        isInviting: true,
        actionSuccessMessage: null,
        errorMessage: null,
      ),
    );
    try {
      final newMember = await _repository.addMember(
        currentState.workspace.id,
        AddMemberRequest(email: email),
      );
      final updatedMembers = [...currentState.members, newMember];
      emit(
        currentState.copyWith(
          members: updatedMembers,
          isInviting: false,
          actionSuccessMessage: 'memberAddedWithEmail:$email',
        ),
      );
      return true;
    } on AppException catch (e) {
      emit(currentState.copyWith(isInviting: false, errorMessage: e.message));
      return false;
    } catch (_) {
      emit(
        currentState.copyWith(
          isInviting: false,
          errorMessage: 'Failed to invite member',
        ),
      );
      return false;
    }
  }

  Future<bool> removeMember(String userId) async {
    final currentState = state;
    if (currentState is! WorkspaceSettingsLoaded) return false;

    emit(currentState.copyWith(actionSuccessMessage: null, errorMessage: null));
    try {
      await _repository.removeMember(currentState.workspace.id, userId);
      final updatedMembers = currentState.members
          .where((m) => m.userId != userId)
          .toList();
      emit(
        currentState.copyWith(
          members: updatedMembers,
          actionSuccessMessage: 'memberRemoved',
        ),
      );
      return true;
    } on AppException catch (e) {
      emit(currentState.copyWith(errorMessage: e.message));
      return false;
    } catch (_) {
      emit(currentState.copyWith(errorMessage: 'Failed to remove member'));
      return false;
    }
  }

  Future<bool> deleteWorkspace() async {
    final currentState = state;
    if (currentState is! WorkspaceSettingsLoaded) return false;

    emit(currentState.copyWith(actionSuccessMessage: null, errorMessage: null));
    try {
      await _repository.deleteWorkspace(currentState.workspace.id);
      await _contextCubit.loadWorkspaces();
      emit(const WorkspaceSettingsState.deleted());
      return true;
    } on AppException catch (e) {
      emit(currentState.copyWith(errorMessage: e.message));
      return false;
    } catch (_) {
      emit(currentState.copyWith(errorMessage: 'Failed to delete workspace'));
      return false;
    }
  }

  void clearError() {
    final currentState = state;
    if (currentState is WorkspaceSettingsLoaded) {
      emit(currentState.copyWith(errorMessage: null));
    }
  }

  void clearMessages() {
    final currentState = state;
    if (currentState is WorkspaceSettingsLoaded) {
      emit(
        currentState.copyWith(actionSuccessMessage: null, errorMessage: null),
      );
    }
  }
}
