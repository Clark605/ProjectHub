import 'package:client/core/errors/app_failure.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

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
  const factory WorkspaceContextState.error(AppFailure failure) =
      _WorkspaceContextError;
}

extension WorkspaceContextStateX on WorkspaceContextState {
  /// The active workspace ID if the state is loaded, or null otherwise.
  int? get activeWorkspaceId => whenOrNull(loaded: (_, a) => a.id);
}
