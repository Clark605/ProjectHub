import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';
import 'package:client/core/widgets/app_danger_zone.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_details_card.dart';
import 'package:client/core/widgets/app_error_banner.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_members_card.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_settings_skeleton.dart';
import 'package:client/features/workspaces/ui/workspace_settings_screen.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class _MockRepo implements WorkspaceRepository {
  WorkspaceDto workspace;
  List<MemberDto> members;
  Future<WorkspaceDto> Function(int id, UpdateWorkspaceRequest r)?
  onUpdateWorkspace;

  _MockRepo({required this.workspace, required this.members});

  @override
  Future<List<WorkspaceDto>> getWorkspaces() async => [workspace];
  @override
  Future<WorkspaceDto> getWorkspace(
    int id, {
    bool forceRefresh = false,
  }) async => workspace;
  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest r) async =>
      workspace;
  @override
  Future<WorkspaceDto> updateWorkspace(int id, UpdateWorkspaceRequest r) async {
    if (onUpdateWorkspace != null) {
      return onUpdateWorkspace!(id, r);
    }
    workspace = workspace.copyWith(name: r.name, description: r.description);
    return workspace;
  }

  @override
  Future<void> deleteWorkspace(int id) async {}
  @override
  Future<List<MemberDto>> getMembers(
    int wid, {
    bool forceRefresh = false,
  }) async => members;
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

  @override
  bool hasCachedSettings(int workspaceId) => false;
  @override
  void clearCache([int? workspaceId]) {}
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
        home: WorkspaceSettingsScreen(cubit: settingsCubit),
      ),
    );
  }

  testWidgets('WorkspaceSettingsScreen renders settings cards for Owner', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(WorkspaceDetailsCard), findsOneWidget);
    expect(find.byType(WorkspaceMembersCard), findsOneWidget);
    expect(find.byType(AppDangerZone), findsOneWidget);
    expect(find.text('Alpha Team'), findsWidgets);
  });

  testWidgets(
    'WorkspaceSettingsScreen shows lock and denies access for Member role',
    (tester) async {
      repo.workspace = repo.workspace.copyWith(
        membership: const WorkspaceMembershipDto(role: 'Member'),
      );
      await contextCubit.loadWorkspaces();

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(WorkspaceDetailsCard), findsNothing);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    },
  );

  testWidgets('Tapping Save Details updates workspace name', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 100));

    final nameField = find.widgetWithText(TextFormField, 'Alpha Team');
    await tester.enterText(nameField, 'Alpha Team Renamed');

    await tester.tap(find.text('Save Details'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(repo.workspace.name, 'Alpha Team Renamed');
  });

  testWidgets(
    'WorkspaceSettingsScreen resolves WorkspaceContextCubit from getIt when pushed without ancestor BlocProvider',
    (tester) async {
      getIt.registerSingleton<WorkspaceContextCubit>(contextCubit);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WorkspaceSettingsScreen(cubit: settingsCubit),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(WorkspaceDetailsCard), findsOneWidget);
    },
  );

  testWidgets(
    'WorkspaceSettingsScreen accepts contextCubit directly via constructor',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WorkspaceSettingsScreen(
            cubit: settingsCubit,
            contextCubit: contextCubit,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(WorkspaceDetailsCard), findsOneWidget);
    },
  );

  testWidgets(
    'WorkspaceMembersCard renders cleanly without overflow on narrow screens',
    (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(WorkspaceMembersCard), findsOneWidget);
      expect(find.text('Add Member'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'WorkspaceSettingsScreen renders WorkspaceSettingsSkeleton when in loading state',
    (tester) async {
      final loadingCubit = WorkspaceSettingsCubit(repo, contextCubit);
      loadingCubit.emit(const WorkspaceSettingsState.loading());

      await tester.pumpWidget(
        BlocProvider<WorkspaceContextCubit>.value(
          value: contextCubit,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WorkspaceSettingsScreen(cubit: loadingCubit),
          ),
        ),
      );

      expect(find.byType(WorkspaceSettingsSkeleton), findsOneWidget);
      await loadingCubit.close();
    },
  );

  testWidgets(
    'WorkspaceSettingsScreen renders WorkspaceSettingsSkeleton when in initial state without crashing',
    (tester) async {
      final initialCubit = WorkspaceSettingsCubit(repo, contextCubit);

      await tester.pumpWidget(
        BlocProvider<WorkspaceContextCubit>.value(
          value: contextCubit,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: WorkspaceSettingsScreen(cubit: initialCubit),
          ),
        ),
      );

      expect(find.byType(WorkspaceSettingsSkeleton), findsOneWidget);
      expect(tester.takeException(), isNull);
      await initialCubit.close();
    },
  );

  testWidgets(
    'WorkspaceSettingsScreen renders AppErrorBanner when errorMessage is set and dismisses on button tap',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppErrorBanner), findsNothing);

      repo.onUpdateWorkspace = (id, req) => throw Exception('Failed to update');
      await settingsCubit.updateDetails('Bad Name', 'Bad Desc', 'teal');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(AppErrorBanner), findsOneWidget);
      expect(find.text('Failed to update workspace details'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.byType(AppErrorBanner), findsNothing);
    },
  );

  testWidgets(
    'WorkspaceSettingsScreen navigates to RouteNames.shell on delete',
    (tester) async {
      String? pushedRoute;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: (settings) {
            if (settings.name == RouteNames.shell) {
              pushedRoute = settings.name;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(body: Text('Shell Screen')),
              );
            }
            return MaterialPageRoute(
              builder: (_) => WorkspaceSettingsScreen(
                cubit: settingsCubit,
                contextCubit: contextCubit,
              ),
            );
          },
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await settingsCubit.deleteWorkspace();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(pushedRoute, RouteNames.shell);
      expect(find.text('Shell Screen'), findsOneWidget);
    },
  );
}
