import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';

part 'workspace_settings_state.freezed.dart';

sealed class WorkspaceAction {}
class ActionDetailsUpdated extends WorkspaceAction {}
class ActionMemberAdded extends WorkspaceAction {}
class ActionMemberAddedWithEmail extends WorkspaceAction {
  final String email;
  ActionMemberAddedWithEmail(this.email);
}
class ActionMemberRemoved extends WorkspaceAction {}

@freezed
sealed class WorkspaceSettingsState with _$WorkspaceSettingsState {
  const factory WorkspaceSettingsState.initial() = WorkspaceSettingsInitial;
  const factory WorkspaceSettingsState.loading() = WorkspaceSettingsLoading;
  const factory WorkspaceSettingsState.loaded({
    required WorkspaceDto workspace,
    required List<MemberDto> members,
    @Default(false) bool isSaving,
    @Default(false) bool isInviting,
    @Default(false) bool isRevalidating,
    WorkspaceAction? successAction,
    String? errorMessage,
  }) = WorkspaceSettingsLoaded;
  const factory WorkspaceSettingsState.deleted() = WorkspaceSettingsDeleted;
  const factory WorkspaceSettingsState.error(String message) =
      WorkspaceSettingsError;
}