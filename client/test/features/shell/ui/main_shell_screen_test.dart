import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/ui/dashboard_screen.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/shell/ui/main_shell_screen.dart';
import 'package:client/features/shell/ui/widgets/mobile_bottom_nav.dart';
import 'package:client/features/shell/ui/widgets/sidebar.dart';
import 'package:client/features/tasks/cubit/my_tasks_cubit.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/tasks/ui/my_tasks_screen.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/ui/widgets/quick_start_dialog.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import 'fakes/shell_test_fakes.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final prefs = PrefsService(sp);
    getIt.registerSingleton<PrefsService>(prefs);

    final authRepo = FakeAuthRepository();
    final authCubit = AppAuthCubit(authRepo);
    getIt.registerSingleton<AppAuthCubit>(authCubit);

    final workspaceRepo = FakeWorkspaceRepository();
    final workspaceCubit = WorkspaceContextCubit(workspaceRepo, prefs);
    getIt.registerSingleton<WorkspaceContextCubit>(workspaceCubit);

    final projectRepo = FakeProjectRepository();
    getIt.registerSingleton<ProjectRepository>(projectRepo);
    getIt.registerFactory<ProjectsListCubit>(() => ProjectsListCubit(projectRepo));

    final activityRepo = FakeActivityRepository();
    getIt.registerSingleton<ActivityRepository>(activityRepo);

    final taskRepo = FakeTaskRepository();
    getIt.registerSingleton<TaskRepository>(taskRepo);

    getIt.registerFactory<DashboardCubit>(
      () => DashboardCubit(activityRepo, projectRepo, taskRepo),
    );
    getIt.registerFactory<MyTasksCubit>(() => MyTasksCubit(taskRepo));
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('MainShellScreen renders Desktop layout with DesktopSidebar', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainShellScreen(initialIndex: 0),
      ),
    );
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

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainShellScreen(initialIndex: 0),
      ),
    );
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

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MainShellScreen(initialIndex: 0),
      ),
    );
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
      final emptyRepo = FakeWorkspaceRepository()..workspaces = [];
      final emptyContextCubit = WorkspaceContextCubit(emptyRepo, prefs);
      getIt.unregister<WorkspaceContextCubit>();
      getIt.registerSingleton<WorkspaceContextCubit>(emptyContextCubit);

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainShellScreen(initialIndex: 0),
        ),
      );
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
      final emptyRepo = FakeWorkspaceRepository()..workspaces = [];
      final emptyContextCubit = WorkspaceContextCubit(emptyRepo, prefs);
      getIt.unregister<WorkspaceContextCubit>();
      getIt.registerSingleton<WorkspaceContextCubit>(emptyContextCubit);

      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainShellScreen(initialIndex: 0),
        ),
      );
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
}
