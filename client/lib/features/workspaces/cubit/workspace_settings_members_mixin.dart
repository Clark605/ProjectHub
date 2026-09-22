import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

mixin WorkspaceSettingsMembersMixin on SafeActionCubit<WorkspaceSettingsState> {
  WorkspaceRepository get repository;

  Future<bool> inviteMember(String email) async {
    final currentState = state;
    if (currentState is! WorkspaceSettingsLoaded) return false;

    emit(
      currentState.copyWith(
        isInviting: true,
        successAction: null,
        errorMessage: null,
      ),
    );

    final success = await safeExecute<bool>(
      () async {
        final newMember = await repository.addMember(
          currentState.workspace.id,
          AddMemberRequest(email: email),
        );
        final updatedMembers = [...currentState.members, newMember];
        emit(
          currentState.copyWith(
            members: updatedMembers,
            isInviting: false,
            successAction: ActionMemberAddedWithEmail(email),
          ),
        );
        return true;
      },
      onError: (message) {
        emit(currentState.copyWith(isInviting: false, errorMessage: message));
      },
      defaultErrorMessage: 'Failed to invite member',
      logTag: 'WorkspaceSettings',
    );

    return success ?? false;
  }

  Future<bool> removeMember(String userId) async {
    final currentState = state;
    if (currentState is! WorkspaceSettingsLoaded) return false;

    emit(currentState.copyWith(successAction: null, errorMessage: null));

    final success = await safeExecute<bool>(
      () async {
        await repository.removeMember(currentState.workspace.id, userId);
        final updatedMembers = currentState.members
            .where((m) => m.userId != userId)
            .toList();
        emit(
          currentState.copyWith(
            members: updatedMembers,
            successAction: ActionMemberRemoved(),
          ),
        );
        return true;
      },
      onError: (message) {
        emit(currentState.copyWith(errorMessage: message));
      },
      defaultErrorMessage: 'Failed to remove member',
      logTag: 'WorkspaceSettings',
    );

    return success ?? false;
  }

  Future<bool> updateMemberRole(String userId, String newRole) async {
    final currentState = state;
    if (currentState is! WorkspaceSettingsLoaded) return false;

    emit(currentState.copyWith(successAction: null, errorMessage: null));

    final success = await safeExecute<bool>(
      () async {
        final updatedMember = await repository.updateMemberRole(
          currentState.workspace.id,
          userId,
          newRole,
        );
        final updatedMembers = currentState.members.map((m) {
          return m.userId == userId ? updatedMember : m;
        }).toList();

        emit(
          currentState.copyWith(
            members: updatedMembers,
            successAction: ActionMemberRoleUpdated(userId, newRole),
          ),
        );
        return true;
      },
      onError: (message) {
        emit(currentState.copyWith(errorMessage: message));
      },
      defaultErrorMessage: 'Failed to update member role',
      logTag: 'WorkspaceSettings',
    );

    return success ?? false;
  }
}
