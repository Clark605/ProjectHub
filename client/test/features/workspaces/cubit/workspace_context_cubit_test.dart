import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

class _FakeWorkspaceRepository implements WorkspaceRepository {
  List<WorkspaceDto> workspaces = [];
  bool shouldThrow = false;
  String errorMessage = 'Server error';

  @override
  Future<List<WorkspaceDto>> getWorkspaces() async {
    if (shouldThrow) throw ServerException(message: errorMessage);
    return workspaces;
  }

  @override
  Future<WorkspaceDto> getWorkspace(int id, {bool forceRefresh = false}) async {
    if (shouldThrow) throw ServerException(message: errorMessage);
    return workspaces.firstWhere((w) => w.id == id);
  }

  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request) async {
    if (shouldThrow) throw ServerException(message: errorMessage);
    return WorkspaceDto(
      id: workspaces.length + 1,
      name: request.name,
      description: request.description,
      membership: const WorkspaceMembershipDto(role: 'Owner'),
    );
  }

  @override
  Future<WorkspaceDto> updateWorkspace(
    int id,
    UpdateWorkspaceRequest request,
  ) async {
    if (shouldThrow) throw ServerException(message: errorMessage);
    return WorkspaceDto(
      id: id,
      name: request.name,
      description: request.description,
      membership: const WorkspaceMembershipDto(role: 'Owner'),
    );
  }

  @override
  Future<void> deleteWorkspace(int id) async {
    if (shouldThrow) throw ServerException(message: errorMessage);
    workspaces.removeWhere((w) => w.id == id);
  }

  @override
  Future<List<MemberDto>> getMembers(
    int workspaceId, {
    bool forceRefresh = false,
  }) async {
    if (shouldThrow) throw ServerException(message: errorMessage);
    return [];
  }

  @override
  Future<MemberDto> addMember(int workspaceId, AddMemberRequest request) async {
    if (shouldThrow) throw ServerException(message: errorMessage);
    return MemberDto(
      userId: 'u_new',
      name: 'New Member',
      email: request.email,
      role: 'Member',
      joinedAt: DateTime.now(),
    );
  }

  @override
  Future<void> removeMember(int workspaceId, String userId) async {
    if (shouldThrow) throw ServerException(message: errorMessage);
  }

  @override
  bool hasCachedSettings(int workspaceId) => false;

  @override
  void clearCache([int? workspaceId]) {}
}

void main() {
  late _FakeWorkspaceRepository repository;
  late PrefsService prefs;
  late SharedPreferences sp;
  late WorkspaceContextCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sp = await SharedPreferences.getInstance();
    prefs = PrefsService(sp);
    repository = _FakeWorkspaceRepository();
    cubit = WorkspaceContextCubit(repository, prefs);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('WorkspaceContextCubit - Context Resolution Engine', () {
    test('initial state is initial', () {
      expect(cubit.state, const WorkspaceContextState.initial());
    });

    test('emits [loading, empty] when user has 0 workspaces', () async {
      repository.workspaces = [];

      final expectedStates = [
        const WorkspaceContextState.loading(),
        const WorkspaceContextState.empty(),
      ];

      expectLater(cubit.stream, emitsInOrder(expectedStates));
      await cubit.loadWorkspaces();
    });

    test(
      'auto-selects single workspace and persists ID when 1 workspace exists',
      () async {
        const single = WorkspaceDto(
          id: 101,
          name: 'Alpha Team',
          description: 'First team',
          membership: WorkspaceMembershipDto(role: 'Owner'),
        );
        repository.workspaces = [single];

        expectLater(
          cubit.stream,
          emitsInOrder([
            const WorkspaceContextState.loading(),
            const WorkspaceContextState.loaded(
              workspaces: [single],
              activeWorkspace: single,
            ),
          ]),
        );

        await cubit.loadWorkspaces();
        expect(prefs.activeWorkspaceId, 101);
      },
    );

    test(
      'restores cached active workspace ID when multiple workspaces exist',
      () async {
        const ws1 = WorkspaceDto(id: 1, name: 'Team One');
        const ws2 = WorkspaceDto(id: 2, name: 'Team Two');
        repository.workspaces = [ws1, ws2];

        await prefs.setActiveWorkspaceId(2);

        expectLater(
          cubit.stream,
          emitsInOrder([
            const WorkspaceContextState.loading(),
            const WorkspaceContextState.loaded(
              workspaces: [ws1, ws2],
              activeWorkspace: ws2,
            ),
          ]),
        );

        await cubit.loadWorkspaces();
        expect(prefs.activeWorkspaceId, 2);
      },
    );

    test('selects first workspace when cached ID not found in list', () async {
      const ws1 = WorkspaceDto(id: 10, name: 'Team 10');
      const ws2 = WorkspaceDto(id: 20, name: 'Team 20');
      repository.workspaces = [ws1, ws2];

      await prefs.setActiveWorkspaceId(999); // Stale ID

      expectLater(
        cubit.stream,
        emitsInOrder([
          const WorkspaceContextState.loading(),
          const WorkspaceContextState.loaded(
            workspaces: [ws1, ws2],
            activeWorkspace: ws1,
          ),
        ]),
      );

      await cubit.loadWorkspaces();
      expect(prefs.activeWorkspaceId, 10);
    });

    test('selectWorkspace updates active workspace and prefs', () async {
      const ws1 = WorkspaceDto(id: 1, name: 'A');
      const ws2 = WorkspaceDto(id: 2, name: 'B');
      repository.workspaces = [ws1, ws2];

      await cubit.loadWorkspaces();

      await cubit.selectWorkspace(ws2);
      expect(prefs.activeWorkspaceId, 2);
      expect(
        cubit.state,
        const WorkspaceContextState.loaded(
          workspaces: [ws1, ws2],
          activeWorkspace: ws2,
        ),
      );
    });

    test(
      'createWorkspace adds new workspace and auto-selects as Owner',
      () async {
        const ws1 = WorkspaceDto(id: 1, name: 'Existing');
        repository.workspaces = [ws1];

        await cubit.loadWorkspaces();

        await cubit.createWorkspace(
          const CreateWorkspaceRequest(name: 'New Product Team'),
        );

        final state = cubit.state.whenOrNull(
          loaded: (list, active) => (list, active),
        );
        expect(state, isNotNull);
        expect(state!.$1.length, 2);
        expect(state.$2.name, 'New Product Team');
        expect(state.$2.membership?.role, 'Owner');
        expect(prefs.activeWorkspaceId, state.$2.id);
      },
    );

    test('emits error state when repository throws exception', () async {
      repository.shouldThrow = true;
      repository.errorMessage = 'Network connection failed';

      expectLater(
        cubit.stream,
        emitsInOrder([
          const WorkspaceContextState.loading(),
          const WorkspaceContextState.error('Network connection failed'),
        ]),
      );

      await cubit.loadWorkspaces();
    });

    test(
      'initializes with loaded state immediately when cached workspace exists',
      () async {
        const cached = WorkspaceDto(
          id: 42,
          name: 'Cached Org',
          membership: WorkspaceMembershipDto(role: 'Owner'),
        );
        await prefs.setCachedActiveWorkspaceRaw(jsonEncode(cached.toJson()));

        final newCubit = WorkspaceContextCubit(repository, prefs);
        expect(
          newCubit.state,
          const WorkspaceContextState.loaded(
            workspaces: [cached],
            activeWorkspace: cached,
          ),
        );
        await newCubit.close();
      },
    );

    test(
      'loadWorkspaces does not emit loading when cached workspace exists',
      () async {
        const cached = WorkspaceDto(
          id: 42,
          name: 'Cached Org',
          membership: WorkspaceMembershipDto(role: 'Owner'),
        );
        await prefs.setCachedActiveWorkspaceRaw(jsonEncode(cached.toJson()));

        const refreshed = WorkspaceDto(
          id: 42,
          name: 'Refreshed Org',
          membership: WorkspaceMembershipDto(role: 'Owner'),
        );
        repository.workspaces = [refreshed];

        final newCubit = WorkspaceContextCubit(repository, prefs);

        expectLater(
          newCubit.stream,
          emitsInOrder([
            const WorkspaceContextState.loaded(
              workspaces: [refreshed],
              activeWorkspace: refreshed,
            ),
          ]),
        );

        await newCubit.loadWorkspaces();
        expect(WorkspaceDto.fromJson(jsonDecode(prefs.getCachedActiveWorkspaceRaw()!)).name, 'Refreshed Org');
        await newCubit.close();
      },
    );

    test('retains cached loaded state when background refresh fails', () async {
      const cached = WorkspaceDto(
        id: 42,
        name: 'Cached Org',
        membership: WorkspaceMembershipDto(role: 'Owner'),
      );
      await prefs.setCachedActiveWorkspaceRaw(jsonEncode(cached.toJson()));

      repository.shouldThrow = true;
      repository.errorMessage = 'Network offline';

      final newCubit = WorkspaceContextCubit(repository, prefs);

      await newCubit.loadWorkspaces();

      expect(
        newCubit.state,
        const WorkspaceContextState.loaded(
          workspaces: [cached],
          activeWorkspace: cached,
        ),
      );
      await newCubit.close();
    });
  });
}
