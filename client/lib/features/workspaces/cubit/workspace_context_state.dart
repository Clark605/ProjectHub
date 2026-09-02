import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:client/features/workspaces/data/models/workspace_dto.dart';

part 'workspace_context_state.freezed.dart';

@freezed
sealed class WorkspaceContextState with _$WorkspaceContextState {
  const factory WorkspaceContextState.initial() = _WorkspaceContextInitial;
  const factory WorkspaceContextState.loading() = _WorkspaceContextLoading;
  const factory WorkspaceContextState.loaded({
    required List<WorkspaceDto> workspaces,
    required WorkspaceDto activeWorkspace,
  }) = _WorkspaceContextLoaded;
  const factory WorkspaceContextState.empty() = _WorkspaceContextEmpty;
  const factory WorkspaceContextState.error(String message) =
      _WorkspaceContextError;
}
