import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

class MockWorkspaceRepository extends Mock implements WorkspaceRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const UpdateWorkspaceRequest(name: 'Fallback', accentColor: 'blue'),
    );
    registerFallbackValue(const AddMemberRequest(email: 'fallback@test.com'));
  });

  group('WorkspaceSettingsCubit', () {
    late MockWorkspaceRepository repository;

    const testWorkspace = WorkspaceDto(
      id: 1,
      name: 'Acme Corp',
      description: 'Main org',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    );

    final testMembers = [
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

    setUp(() {
      repository = MockWorkspaceRepository();
    });

    test('initial state is initial', () {
      final cubit = WorkspaceSettingsCubit(repository);
      expect(cubit.state, const WorkspaceSettingsState.initial());
      cubit.close();
    });

    blocTest<WorkspaceSettingsCubit, WorkspaceSettingsState>(
      'loadSettings emits loading then loaded on success',
      build: () {
        when(() => repository.hasCachedSettings(1)).thenReturn(false);
        when(
          () => repository.getWorkspace(1, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => testWorkspace);
        when(
          () => repository.getMembers(1, forceRefresh: any(named: 'forceRefresh')),
        ).thenAnswer((_) async => testMembers);
        return WorkspaceSettingsCubit(repository);
      },
      act: (cubit) => cubit.loadSettings(1),
      expect: () => [
        const WorkspaceSettingsState.loading(),
        isA<WorkspaceSettingsLoaded>()
            .having((s) => s.workspace.name, 'name', 'Acme Corp')
            .having((s) => s.members.length, 'members', 2),
      ],
      verify: (_) {
        verify(() => repository.getWorkspace(1, forceRefresh: false)).called(1);
        verify(() => repository.getMembers(1, forceRefresh: false)).called(1);
      },
    );

    blocTest<WorkspaceSettingsCubit, WorkspaceSettingsState>(
      'updateDetails updates workspace and sets success message',
      build: () {
        when(
          () => repository.updateWorkspace(1, any()),
        ).thenAnswer(
          (_) async => testWorkspace.copyWith(
            name: 'New Acme Name',
            description: 'New Desc',
            accentColor: 'violet',
          ),
        );
        return WorkspaceSettingsCubit(repository);
      },
      seed: () => const WorkspaceSettingsState.loaded(
        workspace: testWorkspace,
        members: [],
      ),
      act: (cubit) => cubit.updateDetails(
        'New Acme Name',
        'New Desc',
        'violet',
      ),
      expect: () => [
        isA<WorkspaceSettingsLoaded>().having((s) => s.isSaving, 'isSaving', true),
        isA<WorkspaceSettingsLoaded>()
            .having((s) => s.workspace.name, 'name', 'New Acme Name')
            .having((s) => s.workspace.description, 'description', 'New Desc')
            .having((s) => s.workspace.accentColor, 'accentColor', 'violet')
            .having((s) => s.isSaving, 'isSaving', false)
            .having((s) => s.successAction, 'successAction', isA<ActionDetailsUpdated>()),
      ],
      verify: (_) {
        verify(
          () => repository.updateWorkspace(
            1,
            const UpdateWorkspaceRequest(
              name: 'New Acme Name',
              description: 'New Desc',
              accentColor: 'violet',
            ),
          ),
        ).called(1);
      },
    );

    blocTest<WorkspaceSettingsCubit, WorkspaceSettingsState>(
      'inviteMember adds member to list and sets success message with email',
      build: () {
        when(
          () => repository.addMember(1, any()),
        ).thenAnswer(
          (_) async => MemberDto(
            userId: 'u_new',
            name: 'New Colleague',
            email: 'colleague@test.com',
            role: 'Member',
            joinedAt: DateTime(2026, 1, 3),
          ),
        );
        return WorkspaceSettingsCubit(repository);
      },
      seed: () => WorkspaceSettingsState.loaded(
        workspace: testWorkspace,
        members: testMembers,
      ),
      act: (cubit) => cubit.inviteMember('colleague@test.com'),
      expect: () => [
        isA<WorkspaceSettingsLoaded>().having((s) => s.isInviting, 'isInviting', true),
        isA<WorkspaceSettingsLoaded>()
            .having((s) => s.members.length, 'members count', 3)
            .having((s) => s.members.last.email, 'email', 'colleague@test.com')
            .having((s) => s.isInviting, 'isInviting', false)
            .having(
              (s) => s.successAction,
              'successAction',
              isA<ActionMemberAddedWithEmail>(),
            ),
      ],
      verify: (_) {
        verify(
          () => repository.addMember(
            1,
            const AddMemberRequest(email: 'colleague@test.com'),
          ),
        ).called(1);
      },
    );

    blocTest<WorkspaceSettingsCubit, WorkspaceSettingsState>(
      'removeMember removes member from list and sets success message',
      build: () {
        when(() => repository.removeMember(1, 'u2')).thenAnswer((_) async {});
        return WorkspaceSettingsCubit(repository);
      },
      seed: () => WorkspaceSettingsState.loaded(
        workspace: testWorkspace,
        members: testMembers,
      ),
      act: (cubit) => cubit.removeMember('u2'),
      expect: () => [
        isA<WorkspaceSettingsLoaded>()
            .having((s) => s.members.length, 'members count', 1)
            .having(
              (s) => s.successAction,
              'successAction',
              isA<ActionMemberRemoved>(),
            ),
      ],
      verify: (_) {
        verify(() => repository.removeMember(1, 'u2')).called(1);
      },
    );

    blocTest<WorkspaceSettingsCubit, WorkspaceSettingsState>(
      'updateMemberRole updates role in member list and emits ActionMemberRoleUpdated',
      build: () {
        when(
          () => repository.updateMemberRole(1, 'u2', 'Owner'),
        ).thenAnswer(
          (_) async => testMembers[1].copyWith(role: 'Owner'),
        );
        return WorkspaceSettingsCubit(repository);
      },
      seed: () => WorkspaceSettingsState.loaded(
        workspace: testWorkspace,
        members: testMembers,
      ),
      act: (cubit) => cubit.updateMemberRole('u2', 'Owner'),
      expect: () => [
        isA<WorkspaceSettingsLoaded>()
            .having(
              (s) => s.members.firstWhere((m) => m.userId == 'u2').role,
              'role',
              'Owner',
            )
            .having(
              (s) => s.successAction,
              'successAction',
              isA<ActionMemberRoleUpdated>(),
            ),
      ],
      verify: (_) {
        verify(() => repository.updateMemberRole(1, 'u2', 'Owner')).called(1);
      },
    );

    blocTest<WorkspaceSettingsCubit, WorkspaceSettingsState>(
      'updateMemberRole sets errorMessage when repo fails',
      build: () {
        when(
          () => repository.updateMemberRole(1, 'u2', 'Owner'),
        ).thenThrow(const ServerException(message: 'Role update failed'));
        return WorkspaceSettingsCubit(repository);
      },
      seed: () => WorkspaceSettingsState.loaded(
        workspace: testWorkspace,
        members: testMembers,
      ),
      act: (cubit) => cubit.updateMemberRole('u2', 'Owner'),
      expect: () => [
        isA<WorkspaceSettingsLoaded>().having(
          (s) => s.errorMessage,
          'errorMessage',
          'Role update failed',
        ),
      ],
    );

    blocTest<WorkspaceSettingsCubit, WorkspaceSettingsState>(
      'deleteWorkspace emits deleted state',
      build: () {
        when(() => repository.deleteWorkspace(1)).thenAnswer((_) async {});
        return WorkspaceSettingsCubit(repository);
      },
      seed: () => WorkspaceSettingsState.loaded(
        workspace: testWorkspace,
        members: testMembers,
      ),
      act: (cubit) => cubit.deleteWorkspace(),
      expect: () => [
        const WorkspaceSettingsState.deleted(),
      ],
      verify: (_) {
        verify(() => repository.deleteWorkspace(1)).called(1);
      },
    );
  });
}
