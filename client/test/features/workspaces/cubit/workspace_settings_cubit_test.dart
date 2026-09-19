import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

class _FakeSettingsRepository extends Fake implements WorkspaceRepository {
  WorkspaceDto workspace = const WorkspaceDto(
    id: 1,
    name: 'Acme Corp',
    description: 'Main org',
    membership: WorkspaceMembershipDto(role: 'Owner'),
  );

  @override
  void setActiveWorkspace(WorkspaceDto? ws) {}

  List<MemberDto> members = [
    MemberDto(
      userId: 'u1',
      name: 'Owner User',
      email: 'owner@acme.com',
      role: 'Owner',
      joinedAt: DateTime(2026, 1, 1),
    ),
    MemberDto(
      userId: 'u2',
      name: 'Member User',
      email: 'member@acme.com',
      role: 'Member',
      joinedAt: DateTime(2026, 1, 2),
    ),
  ];

  bool shouldFail = false;

  @override
  Future<List<WorkspaceDto>> getWorkspaces() async => [workspace];

  @override
  Future<WorkspaceDto> getWorkspace(int id, {bool forceRefresh = false}) async {
    if (shouldFail) throw const ServerException(message: 'Server error');
    return workspace;
  }

  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request) async =>
      workspace;

  @override
  Future<WorkspaceDto> updateWorkspace(
    int id,
    UpdateWorkspaceRequest request,
  ) async {
    if (shouldFail) throw const ServerException(message: 'Update failed');
    workspace = workspace.copyWith(
      name: request.name,
      description: request.description,
      accentColor: request.accentColor,
    );
    return workspace;
  }

  @override
  Future<void> deleteWorkspace(int id) async {
    if (shouldFail) throw const ServerException(message: 'Delete failed');
  }

  @override
  Future<List<MemberDto>> getMembers(
    int workspaceId, {
    bool forceRefresh = false,
  }) async {
    if (shouldFail) throw const ServerException(message: 'Get members failed');
    return members;
  }

  @override
  Future<MemberDto> addMember(int workspaceId, AddMemberRequest request) async {
    if (shouldFail) throw const ServerException(message: 'Invite failed');
    return MemberDto(
      userId: 'u_new',
      name: 'New Colleague',
      email: request.email,
      role: 'Member',
      joinedAt: DateTime.now(),
    );
  }

  @override
  Future<void> removeMember(int workspaceId, String userId) async {
    if (shouldFail) throw const ServerException(message: 'Remove failed');
    members.removeWhere((m) => m.userId != userId);
  }

  @override
  bool hasCachedSettings(int workspaceId) => false;

  @override
  void clearCache([int? workspaceId]) {}
}

void main() {
  late _FakeSettingsRepository repository;
  late PrefsService prefs;
  late WorkspaceContextCubit contextCubit;
  late WorkspaceSettingsCubit cubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    prefs = PrefsService(sharedPrefs);
    repository = _FakeSettingsRepository();
    contextCubit = WorkspaceContextCubit(repository, prefs);
    cubit = WorkspaceSettingsCubit(repository, contextCubit);
  });

  tearDown(() {
    cubit.close();
    contextCubit.close();
  });

  group('WorkspaceSettingsCubit', () {
    test('initial state is initial', () {
      expect(cubit.state, const WorkspaceSettingsState.initial());
    });

    test('loadSettings emits loading then loaded on success', () async {
      expectLater(
        cubit.stream,
        emitsInOrder([
          const WorkspaceSettingsState.loading(),
          isA<WorkspaceSettingsLoaded>()
              .having((s) => s.workspace.name, 'name', 'Acme Corp')
              .having((s) => s.members.length, 'members', 2),
        ]),
      );

      await cubit.loadSettings(1);
    });

    test('updateDetails updates workspace and sets success message', () async {
      await cubit.loadSettings(1);

      final success = await cubit.updateDetails(
        'New Acme Name',
        'New Desc',
        'violet',
      );

      expect(success, isTrue);
      final state = cubit.state as WorkspaceSettingsLoaded;
      expect(state.workspace.name, 'New Acme Name');
      expect(state.workspace.description, 'New Desc');
      expect(state.workspace.accentColor, 'violet');
      expect(state.successAction, isA<ActionDetailsUpdated>());
    });

    test(
      'inviteMember adds member to list and sets success message with email',
      () async {
        await cubit.loadSettings(1);

        final success = await cubit.inviteMember('colleague@test.com');

        expect(success, isTrue);
        final state = cubit.state as WorkspaceSettingsLoaded;
        expect(state.members.length, 3);
        expect(state.members.last.email, 'colleague@test.com');
        expect(state.successAction, isA<ActionMemberAddedWithEmail>());
      },
    );

    test(
      'removeMember removes member from list and sets success message',
      () async {
        await cubit.loadSettings(1);

        final success = await cubit.removeMember('u2');

        expect(success, isTrue);
        final state = cubit.state as WorkspaceSettingsLoaded;
        expect(state.successAction, isA<ActionMemberRemoved>());
      },
    );

    test('deleteWorkspace emits deleted state', () async {
      await cubit.loadSettings(1);

      final success = await cubit.deleteWorkspace();

      expect(success, isTrue);
      expect(cubit.state, const WorkspaceSettingsState.deleted());
    });
  });
}
