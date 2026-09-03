import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';

part 'workspace_settings_state.freezed.dart';

@freezed
sealed class WorkspaceSettingsState with _$WorkspaceSettingsState {
  const factory WorkspaceSettingsState.initial() = WorkspaceSettingsInitial;
  const factory WorkspaceSettingsState.loading() = WorkspaceSettingsLoading;
  const factory WorkspaceSettingsState.loaded({
    required WorkspaceDto workspace,
    required List<MemberDto> members,
    @Default(false) bool isSaving,
    @Default(false) bool isInviting,
    String? actionSuccessMessage,
    String? errorMessage,
  }) = WorkspaceSettingsLoaded;
  const factory WorkspaceSettingsState.deleted() = WorkspaceSettingsDeleted;
  const factory WorkspaceSettingsState.error(String message) =
      WorkspaceSettingsError;
}
