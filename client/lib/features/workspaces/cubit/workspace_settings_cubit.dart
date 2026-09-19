import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_members_mixin.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

@injectable
class WorkspaceSettingsCubit extends SafeActionCubit<WorkspaceSettingsState>
    with WorkspaceSettingsMembersMixin {
  @override
  final WorkspaceRepository repository;

  WorkspaceSettingsCubit(this.repository)
    : super(const WorkspaceSettingsState.initial());

  Future<void> loadSettings(
    int workspaceId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && repository.hasCachedSettings(workspaceId)) {
      final cachedWorkspace = await repository.getWorkspace(workspaceId);
      final cachedMembers = await repository.getMembers(workspaceId);
      emit(
        WorkspaceSettingsState.loaded(
          workspace: cachedWorkspace,
          members: cachedMembers,
          isRevalidating: true,
        ),
      );

      // Revalidate in background (stale-while-revalidate)
      await safeExecute(
        () async {
          final freshWorkspace = await repository.getWorkspace(
            workspaceId,
            forceRefresh: true,
          );
          final freshMembers = await repository.getMembers(
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
        },
        onError: (_) {
          final currentState = state;
          if (currentState is WorkspaceSettingsLoaded) {
            emit(currentState.copyWith(isRevalidating: false));
          }
        },
        logTag: 'WorkspaceSettingsRevalidate',
      );
      return;
    }

    emit(const WorkspaceSettingsState.loading());
    await safeExecute(
      () async {
        final workspace = await repository.getWorkspace(
          workspaceId,
          forceRefresh: forceRefresh,
        );
        final members = await repository.getMembers(
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
      },
      onError: (message) => emit(WorkspaceSettingsState.error(message)),
      defaultErrorMessage: 'Failed to load workspace settings',
      logTag: 'WorkspaceSettings',
    );
  }

  Future<bool> updateDetails(
    String name,
    String description,
    String accentColor,
  ) async {
    final currentState = state;
    if (currentState is! WorkspaceSettingsLoaded) return false;

    emit(
      currentState.copyWith(
        isSaving: true,
        successAction: null,
        errorMessage: null,
      ),
    );

    final success = await safeExecute<bool>(
      () async {
        final updated = await repository.updateWorkspace(
          currentState.workspace.id,
          UpdateWorkspaceRequest(
            name: name,
            description: description,
            accentColor: accentColor,
          ),
        );

        emit(
          currentState.copyWith(
            workspace: updated,
            isSaving: false,
            successAction: ActionDetailsUpdated(),
          ),
        );
        return true;
      },
      onError: (message) {
        emit(currentState.copyWith(isSaving: false, errorMessage: message));
      },
      defaultErrorMessage: 'Failed to update workspace details',
      logTag: 'WorkspaceSettings',
    );

    return success ?? false;
  }

  Future<bool> deleteWorkspace() async {
    final currentState = state;
    if (currentState is! WorkspaceSettingsLoaded) return false;

    emit(currentState.copyWith(successAction: null, errorMessage: null));

    final success = await safeExecute<bool>(
      () async {
        await repository.deleteWorkspace(currentState.workspace.id);
        emit(const WorkspaceSettingsState.deleted());
        return true;
      },
      onError: (message) {
        emit(currentState.copyWith(errorMessage: message));
      },
      defaultErrorMessage: 'Failed to delete workspace',
      logTag: 'WorkspaceSettings',
    );

    return success ?? false;
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
      emit(currentState.copyWith(successAction: null, errorMessage: null));
    }
  }
}
