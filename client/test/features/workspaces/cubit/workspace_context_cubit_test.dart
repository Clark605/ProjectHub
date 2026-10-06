import 'dart:convert';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

class MockWorkspaceRepository extends Mock implements WorkspaceRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const CreateWorkspaceRequest(name: 'Test Workspace'),
    );
    registerFallbackValue(
      const WorkspaceDto(id: 1, name: 'Fallback Workspace'),
    );
  });

  group('WorkspaceContextCubit', () {
    late MockWorkspaceRepository repository;
    late PrefsService prefs;
    late SharedPreferences sp;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sp = await SharedPreferences.getInstance();
      prefs = PrefsService(sp);
      repository = MockWorkspaceRepository();

      when(() => repository.activeWorkspaceChanges).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => repository.setActiveWorkspace(any())).thenReturn(null);
    });

    test('initial state is initial', () {
      final cubit = WorkspaceContextCubit(repository, prefs);
      expect(cubit.state, const WorkspaceContextState.initial());
      cubit.close();
    });

    blocTest<WorkspaceContextCubit, WorkspaceContextState>(
      'emits [loading, empty] when user has 0 workspaces',
      build: () {
        when(() => repository.getWorkspaces()).thenAnswer((_) async => []);
        return WorkspaceContextCubit(repository, prefs);
      },
      act: (cubit) => cubit.loadWorkspaces(),
      expect: () => [
        const WorkspaceContextState.loading(),
        const WorkspaceContextState.empty(),
      ],
      verify: (_) {
        verify(() => repository.setActiveWorkspace(null)).called(1);
      },
    );

    const single = WorkspaceDto(
      id: 101,
      name: 'Alpha Team',
      description: 'First team',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    );

    blocTest<WorkspaceContextCubit, WorkspaceContextState>(
      'auto-selects single workspace and persists ID when 1 workspace exists',
      build: () {
        when(() => repository.getWorkspaces()).thenAnswer((_) async => [single]);
        return WorkspaceContextCubit(repository, prefs);
      },
      act: (cubit) => cubit.loadWorkspaces(),
      expect: () => [
        const WorkspaceContextState.loading(),
        const WorkspaceContextState.loaded(
          workspaces: [single],
          activeWorkspace: single,
        ),
      ],
      verify: (_) {
        expect(prefs.activeWorkspaceId, 101);
      },
    );

    const ws1 = WorkspaceDto(id: 1, name: 'Team One');
    const ws2 = WorkspaceDto(id: 2, name: 'Team Two');

    blocTest<WorkspaceContextCubit, WorkspaceContextState>(
      'restores cached active workspace ID when multiple workspaces exist',
      setUp: () async {
        await prefs.setActiveWorkspaceId(2);
      },
      build: () {
        when(() => repository.getWorkspaces()).thenAnswer((_) async => [ws1, ws2]);
        return WorkspaceContextCubit(repository, prefs);
      },
      act: (cubit) => cubit.loadWorkspaces(),
      expect: () => [
        const WorkspaceContextState.loading(),
        const WorkspaceContextState.loaded(
          workspaces: [ws1, ws2],
          activeWorkspace: ws2,
        ),
      ],
      verify: (_) {
        expect(prefs.activeWorkspaceId, 2);
      },
    );

    const ws10 = WorkspaceDto(id: 10, name: 'Team 10');
    const ws20 = WorkspaceDto(id: 20, name: 'Team 20');

    blocTest<WorkspaceContextCubit, WorkspaceContextState>(
      'selects first workspace when cached ID not found in list',
      setUp: () async {
        await prefs.setActiveWorkspaceId(999);
      },
      build: () {
        when(
          () => repository.getWorkspaces(),
        ).thenAnswer((_) async => [ws10, ws20]);
        return WorkspaceContextCubit(repository, prefs);
      },
      act: (cubit) => cubit.loadWorkspaces(),
      expect: () => [
        const WorkspaceContextState.loading(),
        const WorkspaceContextState.loaded(
          workspaces: [ws10, ws20],
          activeWorkspace: ws10,
        ),
      ],
      verify: (_) {
        expect(prefs.activeWorkspaceId, 10);
      },
    );

    blocTest<WorkspaceContextCubit, WorkspaceContextState>(
      'selectWorkspace updates active workspace and prefs',
      build: () => WorkspaceContextCubit(repository, prefs),
      seed: () => const WorkspaceContextState.loaded(
        workspaces: [ws1, ws2],
        activeWorkspace: ws1,
      ),
      act: (cubit) => cubit.selectWorkspace(ws2),
      expect: () => [
        const WorkspaceContextState.loaded(
          workspaces: [ws1, ws2],
          activeWorkspace: ws2,
        ),
      ],
      verify: (_) {
        expect(prefs.activeWorkspaceId, 2);
        verify(() => repository.setActiveWorkspace(ws2)).called(1);
      },
    );

    blocTest<WorkspaceContextCubit, WorkspaceContextState>(
      'createWorkspace adds new workspace and auto-selects as Owner',
      build: () {
        when(
          () => repository.createWorkspace(any()),
        ).thenAnswer(
          (_) async => const WorkspaceDto(
            id: 2,
            name: 'New Product Team',
            membership: WorkspaceMembershipDto(role: 'Owner'),
          ),
        );
        return WorkspaceContextCubit(repository, prefs);
      },
      seed: () => const WorkspaceContextState.loaded(
        workspaces: [ws1],
        activeWorkspace: ws1,
      ),
      act: (cubit) => cubit.createWorkspace(
        const CreateWorkspaceRequest(name: 'New Product Team'),
      ),
      expect: () => [
        isA<WorkspaceContextState>().having(
          (s) => s.maybeWhen(
            loaded: (list, active) =>
                list.length == 2 &&
                active.name == 'New Product Team' &&
                active.membership?.role == 'Owner',
            orElse: () => false,
          ),
          'loaded with new workspace as Owner',
          isTrue,
        ),
      ],
      verify: (_) {
        expect(prefs.activeWorkspaceId, 2);
      },
    );

    blocTest<WorkspaceContextCubit, WorkspaceContextState>(
      'emits error state when repository throws exception',
      build: () {
        when(
          () => repository.getWorkspaces(),
        ).thenThrow(const ServerException(message: 'Network connection failed'));
        return WorkspaceContextCubit(repository, prefs);
      },
      act: (cubit) => cubit.loadWorkspaces(),
      expect: () => [
        const WorkspaceContextState.loading(),
        const WorkspaceContextState.error('Network connection failed'),
      ],
    );

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
        verify(() => repository.setActiveWorkspace(cached)).called(1);
        await newCubit.close();
      },
    );

    const cachedOrg = WorkspaceDto(
      id: 42,
      name: 'Cached Org',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    );

    const refreshedOrg = WorkspaceDto(
      id: 42,
      name: 'Refreshed Org',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    );

    blocTest<WorkspaceContextCubit, WorkspaceContextState>(
      'loadWorkspaces does not emit loading when cached workspace exists',
      setUp: () async {
        await prefs.setCachedActiveWorkspaceRaw(jsonEncode(cachedOrg.toJson()));
      },
      build: () {
        when(
          () => repository.getWorkspaces(),
        ).thenAnswer((_) async => [refreshedOrg]);
        return WorkspaceContextCubit(repository, prefs);
      },
      act: (cubit) => cubit.loadWorkspaces(),
      expect: () => [
        const WorkspaceContextState.loaded(
          workspaces: [refreshedOrg],
          activeWorkspace: refreshedOrg,
        ),
      ],
      verify: (_) {
        expect(
          WorkspaceDto.fromJson(
            jsonDecode(prefs.getCachedActiveWorkspaceRaw()!),
          ).name,
          'Refreshed Org',
        );
      },
    );

    blocTest<WorkspaceContextCubit, WorkspaceContextState>(
      'retains cached loaded state when background refresh fails',
      setUp: () async {
        await prefs.setCachedActiveWorkspaceRaw(jsonEncode(cachedOrg.toJson()));
      },
      build: () {
        when(
          () => repository.getWorkspaces(),
        ).thenThrow(const ServerException(message: 'Network offline'));
        return WorkspaceContextCubit(repository, prefs);
      },
      act: (cubit) => cubit.loadWorkspaces(),
      expect: () => [], // No states emitted because failure is suppressed when already loaded
      verify: (cubit) {
        expect(
          cubit.state,
          const WorkspaceContextState.loaded(
            workspaces: [cachedOrg],
            activeWorkspace: cachedOrg,
          ),
        );
      },
    );

    const cachedMember = WorkspaceDto(
      id: 19,
      name: 'ProjectHub',
      membership: WorkspaceMembershipDto(role: 'Member'),
    );
    const serverOwner = WorkspaceDto(
      id: 19,
      name: 'ProjectHub',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    );

    blocTest<WorkspaceContextCubit, WorkspaceContextState>(
      'revalidates cached workspace role from Member to Owner on background refresh',
      setUp: () async {
        await prefs.setActiveWorkspaceId(19);
        await prefs.setCachedActiveWorkspaceRaw(
          jsonEncode(cachedMember.toJson()),
        );
      },
      build: () {
        when(
          () => repository.getWorkspaces(),
        ).thenAnswer((_) async => [serverOwner]);
        return WorkspaceContextCubit(repository, prefs);
      },
      act: (cubit) => cubit.loadWorkspaces(),
      expect: () => [
        const WorkspaceContextState.loaded(
          workspaces: [serverOwner],
          activeWorkspace: serverOwner,
        ),
      ],
      verify: (_) {
        final updatedCache = WorkspaceDto.fromJson(
          jsonDecode(prefs.getCachedActiveWorkspaceRaw()!),
        );
        expect(updatedCache.membership?.role, 'Owner');
      },
    );

    blocTest<WorkspaceContextCubit, WorkspaceContextState>(
      'reset clears repository cache, active workspace prefs, and emits initial state',
      build: () {
        when(() => repository.clearCache()).thenReturn(null);
        return WorkspaceContextCubit(repository, prefs);
      },
      seed: () => const WorkspaceContextState.loaded(
        workspaces: [ws1],
        activeWorkspace: ws1,
      ),
      act: (cubit) => cubit.reset(),
      expect: () => [const WorkspaceContextState.initial()],
      verify: (_) {
        expect(prefs.activeWorkspaceId, isNull);
        expect(prefs.getCachedActiveWorkspaceRaw(), isNull);
        verify(() => repository.clearCache()).called(1);
      },
    );
  });
}
