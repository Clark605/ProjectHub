import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_settings_state.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/core/widgets/app_danger_zone.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_details_card.dart';
import 'package:client/core/widgets/app_error_banner.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_members_card.dart';
import 'package:client/features/workspaces/ui/widgets/workspace_settings_skeleton.dart';
import 'package:client/features/workspaces/ui/workspace_settings_screen.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(
      const UpdateWorkspaceRequest(name: 'Fallback', accentColor: 'blue'),
    );
    registerFallbackValue(const AddMemberRequest(email: 'fallback@test.com'));
  });

  late MockWorkspaceRepository repo;
  late WorkspaceDto currentWorkspace;
  late List<MemberDto> currentMembers;
  late PrefsService prefs;
  late WorkspaceContextCubit contextCubit;
  late WorkspaceSettingsCubit settingsCubit;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    prefs = PrefsService(sp);

    currentWorkspace = const WorkspaceDto(
      id: 1,
      name: 'Alpha Team',
      description: 'Alpha description',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    );
    currentMembers = [
      MemberDto(
        userId: 'u1',
        name: 'Alice Owner',
        email: 'alice@alpha.com',
        role: 'Owner',
        joinedAt: DateTime(2026, 1, 1),
      ),
      MemberDto(
        userId: 'u2',
        name: 'Bob Member',
        email: 'bob@alpha.com',
        role: 'Member',
        joinedAt: DateTime(2026, 1, 2),
      ),
    ];

    repo = MockWorkspaceRepository();
    when(() => repo.activeWorkspace).thenAnswer((_) => currentWorkspace);
    when(
      () => repo.activeWorkspaceChanges,
    ).thenAnswer((_) => const Stream.empty());
    when(() => repo.setActiveWorkspace(any())).thenReturn(null);
    when(
      () => repo.getWorkspaces(),
    ).thenAnswer((_) async => [currentWorkspace]);
    when(
      () => repo.getWorkspace(any(), forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => currentWorkspace);
    when(
      () => repo.getMembers(any(), forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => currentMembers);
    when(() => repo.updateWorkspace(any(), any())).thenAnswer((inv) async {
      final r = inv.positionalArguments[1] as UpdateWorkspaceRequest;
      currentWorkspace = currentWorkspace.copyWith(
        name: r.name,
        description: r.description,
      );
      return currentWorkspace;
    });
    when(() => repo.updateMemberRole(any(), any(), any())).thenAnswer((
      inv,
    ) async {
      final uid = inv.positionalArguments[1] as String;
      final role = inv.positionalArguments[2] as String;
      final index = currentMembers.indexWhere((m) => m.userId == uid);
      if (index != -1) {
        currentMembers[index] = currentMembers[index].copyWith(role: role);
        return currentMembers[index];
      }
      throw Exception('Member not found');
    });
    when(() => repo.deleteWorkspace(any())).thenAnswer((_) async {});
    when(() => repo.hasCachedSettings(any())).thenReturn(false);
    when(() => repo.clearCache(any())).thenReturn(null);

    contextCubit = WorkspaceContextCubit(repo, prefs);
    await contextCubit.loadWorkspaces();

    settingsCubit = WorkspaceSettingsCubit(repo);
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
      currentWorkspace = currentWorkspace.copyWith(
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

    expect(currentWorkspace.name, 'Alpha Team Renamed');
  });

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
      final loadingCubit = WorkspaceSettingsCubit(repo);
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
      final initialCubit = WorkspaceSettingsCubit(repo);

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

      when(
        () => repo.updateWorkspace(any(), any()),
      ).thenAnswer((_) async => throw Exception('Failed to update'));
      await settingsCubit.updateDetails('Bad Name', 'Bad Desc', 'teal');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(find.byType(AppErrorBanner), findsOneWidget);
      expect(find.textContaining('Failed to update'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.byType(AppErrorBanner), findsNothing);
    },
  );

  testWidgets(
    'WorkspaceSettingsScreen can promote a member to Owner via context menu',
    (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 100));

      final popupFinder = find.byType(PopupMenuButton<String>);
      expect(popupFinder, findsWidgets);

      await tester.ensureVisible(popupFinder.at(1));
      await tester.pumpAndSettle();

      await tester.tap(popupFinder.at(1));
      await tester.pumpAndSettle();

      expect(find.text('Promote to Owner'), findsOneWidget);

      await tester.tap(find.text('Promote to Owner'));
      await tester.pumpAndSettle();

      expect(find.text('Change Member Role?'), findsOneWidget);

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(currentMembers.firstWhere((m) => m.userId == 'u2').role, 'Owner');
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
