import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

@lazySingleton
class WorkspaceContextCubit extends SafeActionCubit<WorkspaceContextState> {
  final WorkspaceRepository _repository;
  final PrefsService _prefs;
  StreamSubscription<WorkspaceDto?>? _activeWsSubscription;

  WorkspaceContextCubit(this._repository, this._prefs)
    : super(_resolveInitialState(_prefs, _repository)) {
    _activeWsSubscription = _repository.activeWorkspaceChanges.listen((ws) {
      if (ws == null) {
        state.maybeWhen(
          loaded: (workspaces, _) => loadWorkspaces(),
          orElse: () {},
        );
      } else {
        state.maybeWhen(
          loaded: (workspaces, active) {
            if (active.id == ws.id &&
                (active.name != ws.name ||
                    active.description != ws.description ||
                    active.accentColor != ws.accentColor)) {
              final updatedList =
                  workspaces.map((w) => w.id == ws.id ? ws : w).toList();
              _prefs.setActiveWorkspaceId(ws.id);
              _prefs.setCachedActiveWorkspaceRaw(jsonEncode(ws.toJson()));
              emit(
                WorkspaceContextState.loaded(
                  workspaces: updatedList,
                  activeWorkspace: ws,
                ),
              );
            }
          },
          orElse: () {},
        );
      }
    });
  }

  static WorkspaceContextState _resolveInitialState(
    PrefsService prefs,
    WorkspaceRepository repository,
  ) {
    final cachedRaw = prefs.getCachedActiveWorkspaceRaw();
    if (cachedRaw != null && cachedRaw.isNotEmpty) {
      try {
        final cached = WorkspaceDto.fromJson(jsonDecode(cachedRaw));
        repository.setActiveWorkspace(cached);
        return WorkspaceContextState.loaded(
          workspaces: [cached],
          activeWorkspace: cached,
        );
      } catch (_) {}
    }
    return const WorkspaceContextState.initial();
  }

  Future<void> loadWorkspaces() async {
    final hasLoadedState = state.maybeWhen(
      loaded: (_, _) => true,
      orElse: () => false,
    );
    if (!hasLoadedState) {
      emit(const WorkspaceContextState.loading());
    }

    await safeExecute(
      () async {
        final workspaces = await _repository.getWorkspaces();

        if (workspaces.isEmpty) {
          _repository.setActiveWorkspace(null);
          await _prefs.clearActiveWorkspace();
          emit(const WorkspaceContextState.empty());
          return;
        }

        if (workspaces.length == 1) {
          final single = workspaces.first;
          _repository.setActiveWorkspace(single);
          await _prefs.setActiveWorkspaceId(single.id);
          await _prefs.setCachedActiveWorkspaceRaw(jsonEncode(single.toJson()));
          emit(
            WorkspaceContextState.loaded(
              workspaces: workspaces,
              activeWorkspace: single,
            ),
          );
          return;
        }

        // Multi-workspace resolution (Journey 1/5 & §1 Context Engine)
        final cachedId = _prefs.activeWorkspaceId;
        final matched = cachedId != null
            ? workspaces.where((w) => w.id == cachedId).firstOrNull
            : null;

        final active = matched ?? workspaces.first;
        _repository.setActiveWorkspace(active);
        await _prefs.setActiveWorkspaceId(active.id);
        await _prefs.setCachedActiveWorkspaceRaw(jsonEncode(active.toJson()));

        emit(
          WorkspaceContextState.loaded(
            workspaces: workspaces,
            activeWorkspace: active,
          ),
        );
      },
      onError: (message) {
        final hasLoaded = state.maybeWhen(
          loaded: (_, _) => true,
          orElse: () => false,
        );
        if (!hasLoaded) {
          emit(WorkspaceContextState.error(message));
        }
      },
      defaultErrorMessage: 'An unexpected error occurred',
      logTag: 'WorkspaceContext',
    );
  }

  Future<void> selectWorkspace(WorkspaceDto workspace) async {
    final currentWorkspaces = state.maybeWhen(
      loaded: (workspaces, _) => workspaces,
      orElse: () => null,
    );
    if (currentWorkspaces == null) return;

    _repository.setActiveWorkspace(workspace);
    await _prefs.setActiveWorkspaceId(workspace.id);
    await _prefs.setCachedActiveWorkspaceRaw(jsonEncode(workspace.toJson()));
    emit(
      WorkspaceContextState.loaded(
        workspaces: currentWorkspaces,
        activeWorkspace: workspace,
      ),
    );
  }

  Future<void> createWorkspace(CreateWorkspaceRequest request) async {
    await safeExecute(
      () async {
        final created = await _repository.createWorkspace(request);

        final currentWorkspaces = state.maybeWhen(
          loaded: (workspaces, _) => workspaces,
          orElse: () => <WorkspaceDto>[],
        );

        final updatedList = [...currentWorkspaces, created];
        _repository.setActiveWorkspace(created);
        await _prefs.setActiveWorkspaceId(created.id);
        await _prefs.setCachedActiveWorkspaceRaw(jsonEncode(created.toJson()));

        emit(
          WorkspaceContextState.loaded(
            workspaces: updatedList,
            activeWorkspace: created,
          ),
        );
      },
      onError: (message) => emit(WorkspaceContextState.error(message)),
      defaultErrorMessage: 'Failed to create workspace',
      logTag: 'WorkspaceContext',
    );
  }

  Future<void> reset() async {
    _repository.clearCache();
    await _prefs.clearActiveWorkspace();
    emit(const WorkspaceContextState.initial());
    _repository.setActiveWorkspace(null);
  }

  @override
  Future<void> close() {
    _activeWsSubscription?.cancel();
    return super.close();
  }
}
