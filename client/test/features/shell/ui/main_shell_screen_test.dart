import 'dart:convert';

import 'package:client/core/cubit/app_settings_cubit.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/network/signalr_service.dart';
import 'package:client/core/routes/route_providers.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/ui/dashboard_screen.dart';
import 'package:client/features/profile/cubit/profile_edit_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/shell/ui/main_shell_screen.dart';
import 'package:client/features/shell/ui/widgets/mobile_bottom_nav.dart';
import 'package:client/features/shell/ui/widgets/sidebar.dart';
import 'package:client/features/tasks/cubit/my_tasks_cubit.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/tasks/ui/my_tasks_screen.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/ui/widgets/quick_start_dialog.dart';
import 'package:client/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../helpers/mock_repositories.dart';

class _SpyWorkspaceContextCubit extends WorkspaceContextCubit {
  int loadWorkspacesCallCount = 0;

  _SpyWorkspaceContextCubit(super.repository, super.prefs);

  @override
  Future<void> loadWorkspaces() async {
    loadWorkspacesCallCount++;
    await super.loadWorkspaces();
  }
}

class _SpyProjectsListCubit extends ProjectsListCubit {
  final List<int> loadedWorkspaceIds = [];

  _SpyProjectsListCubit(super.projectRepository);

  @override
  Future<void> loadProjects(
    int workspaceId, {
    bool forceRefresh = false,
    String? filter,
  }) async {
    loadedWorkspaceIds.add(workspaceId);
    await super.loadProjects(
      workspaceId,
      forceRefresh: forceRefresh,
      filter: filter,
    );
  }
}

void main() {
  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final prefs = PrefsService(sp);
    getIt.registerSingleton<PrefsService>(prefs);

    final settingsCubit = AppSettingsCubit(prefs);
    getIt.registerSingleton<AppSettingsCubit>(settingsCubit);

    final authRepo = createMockAuthRepository();
    final authCubit = AppAuthCubit(authRepo);
    getIt.registerSingleton<AppAuthCubit>(authCubit);

    final workspaceRepo = createMockWorkspaceRepository();
    final workspaceCubit = WorkspaceContextCubit(workspaceRepo, prefs);
    getIt.registerSingleton<WorkspaceContextCubit>(workspaceCubit);

    final projectRepo = createMockProjectRepository();
    getIt.registerSingleton<ProjectRepository>(projectRepo);
    getIt.registerFactory<ProjectsListCubit>(
      () => ProjectsListCubit(projectRepo),
    );

    final activityRepo = createMockActivityRepository();
    getIt.registerSingleton<ActivityRepository>(activityRepo);

    final taskRepo = createMockTaskRepository();
    getIt.registerSingleton<TaskRepository>(taskRepo);

    getIt.registerFactory<DashboardCubit>(() => DashboardCubit(workspaceRepo));
    getIt.registerFactory<MyTasksCubit>(() => MyTasksCubit(taskRepo));
    getIt.registerFactory<ProfileEditCubit>(() => ProfileEditCubit(authRepo));

    final signalR = createMockSignalRService();
    getIt.registerSingleton<SignalRService>(signalR);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestApp({int initialIndex = 0}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppSettingsCubit>.value(value: getIt<AppSettingsCubit>()),
        BlocProvider<AppAuthCubit>.value(value: getIt<AppAuthCubit>()),
        BlocProvider<WorkspaceContextCubit>(
          lazy: false,
          create: (_) => getIt<WorkspaceContextCubit>()..loadWorkspaces(),
        ),
        BlocProvider<ProjectsListCubit>.value(
          value: getIt<ProjectsListCubit>(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainShellScreen(initialIndex: initialIndex),
      ),
    );
  }

  testWidgets('MainShellScreen renders Desktop layout with DesktopSidebar', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(Sidebar), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('MainShellScreen renders Mobile layout with MobileBottomNav', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MobileBottomNav), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('MainShellScreen switches to My Tasks tab on selection', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildTestApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(DashboardScreen), findsOneWidget);

    await tester.tap(find.text('My Tasks').first);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MyTasksScreen), findsOneWidget);
  });

  testWidgets(
    'MainShellScreen renders "Create Workspace" and no role badge when user has no workspaces',
    (WidgetTester tester) async {
      final sp = await SharedPreferences.getInstance();
      final prefs = PrefsService(sp);
      final emptyRepo = createMockWorkspaceRepository(workspaces: []);
      final emptyContextCubit = WorkspaceContextCubit(emptyRepo, prefs);
      getIt.unregister<WorkspaceContextCubit>();
      getIt.registerSingleton<WorkspaceContextCubit>(emptyContextCubit);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Create Workspace'), findsWidgets);
      expect(find.text('Owner'), findsNothing);
      expect(find.text('Member'), findsNothing);
      expect(find.byIcon(Icons.settings_outlined), findsNothing);
    },
  );

  testWidgets(
    'Tapping "Create Workspace" in ShellTopBar when user has no workspaces opens QuickStartDialog',
    (WidgetTester tester) async {
      final sp = await SharedPreferences.getInstance();
      final prefs = PrefsService(sp);
      final emptyRepo = createMockWorkspaceRepository(workspaces: []);
      final emptyContextCubit = WorkspaceContextCubit(emptyRepo, prefs);
      getIt.unregister<WorkspaceContextCubit>();
      getIt.registerSingleton<WorkspaceContextCubit>(emptyContextCubit);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(QuickStartDialog), findsOneWidget);

      final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
      nav.pop();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(QuickStartDialog), findsNothing);

      await tester.tap(find.text('Create Workspace').first);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(QuickStartDialog), findsOneWidget);
    },
  );

  testWidgets(
    'QuickStartDialog cannot show twice when WorkspaceContextCubit is already empty and re-emits empty',
    (WidgetTester tester) async {
      final sp = await SharedPreferences.getInstance();
      final prefs = PrefsService(sp);
      final emptyRepo = createMockWorkspaceRepository(workspaces: []);
      final emptyContextCubit = WorkspaceContextCubit(emptyRepo, prefs);
      await emptyContextCubit.loadWorkspaces();

      getIt.unregister<WorkspaceContextCubit>();
      getIt.registerSingleton<WorkspaceContextCubit>(emptyContextCubit);

      await tester.pumpWidget(buildTestApp());
      await tester.pump(const Duration(milliseconds: 100));

      // Trigger another loadWorkspaces while QuickStartDialog is already open
      await emptyContextCubit.loadWorkspaces();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(QuickStartDialog), findsOneWidget);

      // Popping once must dismiss the only dialog on the stack
      final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
      nav.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(QuickStartDialog), findsNothing);
    },
  );

  testWidgets(
    'buildShellRoute performs initial loadProjects in provider create and reloads via listenWhen on workspace switch',
    (WidgetTester tester) async {
      const ws1 = WorkspaceDto(
        id: 1,
        name: 'Workspace One',
        membership: WorkspaceMembershipDto(role: 'Owner'),
      );
      const ws2 = WorkspaceDto(
        id: 2,
        name: 'Workspace Two',
        membership: WorkspaceMembershipDto(role: 'Member'),
      );

      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final prefs = PrefsService(sp);
      await prefs.setActiveWorkspaceId(ws1.id);
      await prefs.setCachedActiveWorkspaceRaw(jsonEncode(ws1.toJson()));

      final workspaceRepo = createMockWorkspaceRepository(
        workspaces: const [ws1, ws2],
        activeWorkspace: ws1,
      );

      final workspaceCubit = WorkspaceContextCubit(workspaceRepo, prefs);
      final projectRepo = createMockProjectRepository();
      final spyProjectsCubit = _SpyProjectsListCubit(projectRepo);

      getIt.unregister<WorkspaceContextCubit>();
      getIt.registerSingleton<WorkspaceContextCubit>(workspaceCubit);
      getIt.unregister<ProjectsListCubit>();
      getIt.registerFactory<ProjectsListCubit>(() => spyProjectsCubit);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AppSettingsCubit>.value(
              value: getIt<AppSettingsCubit>(),
            ),
            BlocProvider<AppAuthCubit>.value(value: getIt<AppAuthCubit>()),
            BlocProvider<WorkspaceContextCubit>.value(value: workspaceCubit),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: buildShellRoute(),
          ),
        ),
      );

      // Provider create immediately triggered initial loadProjects(1)
      expect(spyProjectsCubit.loadedWorkspaceIds, contains(1));
      await tester.pump(const Duration(milliseconds: 100));

      final countBeforeSwitch = spyProjectsCubit.loadedWorkspaceIds.length;

      // Switching to workspace 2 reloads via MainShellScreen listenWhen
      await workspaceCubit.selectWorkspace(ws2);
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        spyProjectsCubit.loadedWorkspaceIds.sublist(countBeforeSwitch),
        contains(2),
      );
    },
  );

  testWidgets(
    'MainShellScreen renders without triggering loadWorkspaces itself',
    (WidgetTester tester) async {
      final sp = await SharedPreferences.getInstance();
      final prefs = PrefsService(sp);
      final repo = createMockWorkspaceRepository();
      final spyCubit = _SpyWorkspaceContextCubit(repo, prefs);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<AppSettingsCubit>.value(
              value: getIt<AppSettingsCubit>(),
            ),
            BlocProvider<AppAuthCubit>.value(value: getIt<AppAuthCubit>()),
            BlocProvider<WorkspaceContextCubit>.value(value: spyCubit),
            BlocProvider<ProjectsListCubit>.value(
              value: getIt<ProjectsListCubit>(),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MainShellScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(spyCubit.loadWorkspacesCallCount, equals(0));
    },
  );

  testWidgets(
    'WorkspaceContextCubit loads workspaces once when provided via create',
    (WidgetTester tester) async {
      final sp = await SharedPreferences.getInstance();
      final prefs = PrefsService(sp);
      final repo = createMockWorkspaceRepository();
      final spyCubit = _SpyWorkspaceContextCubit(repo, prefs);

      await tester.pumpWidget(
        BlocProvider<WorkspaceContextCubit>(
          lazy: false,
          create: (_) => spyCubit..loadWorkspaces(),
          child: const SizedBox(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(spyCubit.loadWorkspacesCallCount, equals(1));
    },
  );
}
