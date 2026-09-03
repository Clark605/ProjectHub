import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_danger_zone.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_details_card.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_members_card.dart';
import 'package:client/features/workspaces/ui/workspaces_screen.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class _MockRepo implements WorkspaceRepository {
  WorkspaceDto workspace;
  List<MemberDto> members;

  _MockRepo({
    required this.workspace,
    required this.members,
  });

  @override
  Future<List<WorkspaceDto>> getWorkspaces() async => [workspace];
  @override
  Future<WorkspaceDto> getWorkspace(int id) async => workspace;
  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest r) async => workspace;
  @override
  Future<WorkspaceDto> updateWorkspace(int id, UpdateWorkspaceRequest r) async {
    workspace = workspace.copyWith(name: r.name, description: r.description);
    return workspace;
  }
  @override
  Future<void> deleteWorkspace(int id) async {}
  @override
  Future<List<MemberDto>> getMembers(int wid) async => members;
  @override
  Future<MemberDto> addMember(int wid, AddMemberRequest r) async => MemberDto(
        userId: 'u_new',
        name: 'New',
        email: r.email,
        role: 'Member',
        joinedAt: DateTime.now(),
      );
  @override
  Future<void> removeMember(int wid, String uid) async {
    members.removeWhere((m) => m.userId == uid);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;
  late PrefsService prefs;
  late WorkspaceContextCubit contextCubit;
  late WorkspaceSettingsCubit settingsCubit;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    prefs = PrefsService(sp);

    repo = _MockRepo(
      workspace: const WorkspaceDto(
        id: 1,
        name: 'Alpha Team',
        description: 'Alpha description',
        membership: WorkspaceMembershipDto(role: 'Owner'),
      ),
      members: [
        MemberDto(
          userId: 'u1',
          name: 'Alice Owner',
          email: 'alice@alpha.com',
          role: 'Owner',
          joinedAt: DateTime(2026, 1, 1),
        ),
      ],
    );

    contextCubit = WorkspaceContextCubit(repo, prefs);
    await contextCubit.loadWorkspaces();

    settingsCubit = WorkspaceSettingsCubit(repo, contextCubit);
    await settingsCubit.loadSettings(1);
    getIt.registerFactory<WorkspaceSettingsCubit>(() => settingsCubit);
  });

  tearDown(() async {
    await settingsCubit.close();
    await contextCubit.close();
    await getIt.reset();
  });

  Widget buildSubject() {
    return BlocProvider<WorkspaceContextCubit>.value(
      value: contextCubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WorkspacesScreen(cubit: settingsCubit),
      ),
    );
  }

  testWidgets('WorkspacesScreen renders settings cards for Owner', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(WorkspaceDetailsCard), findsOneWidget);
    expect(find.byType(WorkspaceMembersCard), findsOneWidget);
    expect(find.byType(WorkspaceDangerZone), findsOneWidget);
    expect(find.text('Alpha Team'), findsWidgets);
  });

  testWidgets('WorkspacesScreen shows lock and denies access for Member role', (
    tester,
  ) async {
    repo.workspace = repo.workspace.copyWith(
      membership: const WorkspaceMembershipDto(role: 'Member'),
    );
    await contextCubit.loadWorkspaces();

    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(WorkspaceDetailsCard), findsNothing);
    expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
  });

  testWidgets('Tapping Save Details updates workspace name', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 100));

    final nameField = find.widgetWithText(TextFormField, 'Alpha Team');
    await tester.enterText(nameField, 'Alpha Team Renamed');

    await tester.tap(find.text('Save Details'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(repo.workspace.name, 'Alpha Team Renamed');
  });
}
