import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';
import 'package:client/features/workspaces/ui/widgets/quick_start_dialog.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_card.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_switcher_sheet.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class _FakeWorkspaceRepository extends Fake implements WorkspaceRepository {
  List<WorkspaceDto> workspaces = [
    const WorkspaceDto(
      id: 1,
      name: 'Engineering Team',
      description: 'Core dev',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    ),
    const WorkspaceDto(
      id: 2,
      name: 'Marketing Guild',
      description: 'Growth and outreach',
      membership: WorkspaceMembershipDto(role: 'Member'),
    ),
  ];

  @override
  WorkspaceDto? get activeWorkspace => workspaces.firstOrNull;

  @override
  Stream<WorkspaceDto?> get activeWorkspaceChanges => const Stream.empty();

  @override
  void setActiveWorkspace(WorkspaceDto? workspace) {}

  @override
  Future<List<WorkspaceDto>> getWorkspaces() async => workspaces;

  @override
  Future<WorkspaceDto> getWorkspace(
    int id, {
    bool forceRefresh = false,
  }) async => workspaces.firstWhere((w) => w.id == id);

  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request) async {
    final created = WorkspaceDto(
      id: workspaces.length + 1,
      name: request.name,
      description: request.description,
      membership: const WorkspaceMembershipDto(role: 'Owner'),
    );
    workspaces.add(created);
    return created;
  }

  @override
  Future<WorkspaceDto> updateWorkspace(
    int id,
    UpdateWorkspaceRequest request,
  ) async {
    final idx = workspaces.indexWhere((w) => w.id == id);
    if (idx != -1) {
      final updated = workspaces[idx].copyWith(
        name: request.name,
        description: request.description,
      );
      workspaces[idx] = updated;
      return updated;
    }
    return WorkspaceDto(
      id: id,
      name: request.name,
      description: request.description,
    );
  }

  @override
  Future<void> deleteWorkspace(int id) async {
    workspaces.removeWhere((w) => w.id == id);
  }

  @override
  Future<List<MemberDto>> getMembers(
    int workspaceId, {
    bool forceRefresh = false,
  }) async => [];

  @override
  Future<MemberDto> addMember(
    int workspaceId,
    AddMemberRequest request,
  ) async => MemberDto(
    userId: 'u_new',
    name: 'New Member',
    email: request.email,
    role: 'Member',
    joinedAt: DateTime.now(),
  );

  @override
  Future<void> removeMember(int workspaceId, String userId) async {}

  @override
  bool hasCachedSettings(int workspaceId) => false;

  @override
  void clearCache([int? workspaceId]) {}
}

void main() {
  late _FakeWorkspaceRepository repository;
  late PrefsService prefs;
  late WorkspaceContextCubit cubit;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    prefs = PrefsService(sp);
    repository = _FakeWorkspaceRepository();
    cubit = WorkspaceContextCubit(repository, prefs);
    getIt.registerSingleton<WorkspaceContextCubit>(cubit);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<WorkspaceContextCubit>.value(
        value: cubit,
        child: const Scaffold(body: WorkspaceSwitcherSheet()),
      ),
    );
  }

  testWidgets(
    'WorkspaceSwitcherSheet renders workspaces and filters by search',
    (tester) async {
      await cubit.loadWorkspaces();

      await tester.pumpWidget(buildTestableWidget());
      await tester.pumpAndSettle();

      // Verify both workspaces rendered via WorkspaceCard
      expect(find.byType(WorkspaceCard), findsNWidgets(2));
      expect(find.text('Engineering Team'), findsOneWidget);
      expect(find.text('Marketing Guild'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'marketing');
      await tester.pumpAndSettle();

      // Only Marketing Guild should remain
      expect(find.text('Marketing Guild'), findsOneWidget);
      expect(find.text('Engineering Team'), findsNothing);
    },
  );

  testWidgets('Selecting a workspace card triggers cubit.selectWorkspace', (
    tester,
  ) async {
    await cubit.loadWorkspaces();

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Tap second workspace
    await tester.tap(find.text('Marketing Guild'));
    await tester.pumpAndSettle();

    // Cubit should now have Marketing Guild (id: 2) as active
    final active = cubit.state.mapOrNull(loaded: (s) => s.activeWorkspace);
    expect(active?.id, 2);
    expect(prefs.activeWorkspaceId, 2);
  });

  testWidgets('Tapping create button opens QuickStartDialog', (tester) async {
    await cubit.loadWorkspaces();

    await tester.pumpWidget(buildTestableWidget());
    await tester.pumpAndSettle();

    // Find and tap "Create New Workspace"
    final createBtn = find.text('Create New Workspace');
    expect(createBtn, findsOneWidget);
    await tester.tap(createBtn);
    await tester.pumpAndSettle();

    // Verify QuickStartDialog opened
    expect(find.byType(QuickStartDialog), findsOneWidget);
  });
}
