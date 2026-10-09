import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_nav_item.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_quick_links.dart';
import 'package:client/features/shell/ui/widgets/sidebar.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  late MockProjectRepository mockProjectRepo;
  late ProjectsListCubit projectsCubit;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final prefs = PrefsService(sp);
    getIt.registerSingleton<PrefsService>(prefs);

    final authRepo = createMockAuthRepository();
    final authCubit = AppAuthCubit(authRepo);
    getIt.registerSingleton<AppAuthCubit>(authCubit);

    mockProjectRepo = MockProjectRepository();
    when(
      () => mockProjectRepo.getProjects(
        any(),
        status: any(named: 'status'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => []);
    when(() => mockProjectRepo.hasCachedProjects(any())).thenReturn(false);
    when(() => mockProjectRepo.clearCache(any())).thenReturn(null);
    getIt.registerSingleton<ProjectRepository>(mockProjectRepo);

    projectsCubit = ProjectsListCubit(mockProjectRepo);
  });

  tearDown(() async {
    await projectsCubit.close();
    await getIt.reset();
  });

  Widget buildTestWidget({
    required ProjectsListCubit cubit,
    ValueChanged<int>? onProjectSelected,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<AppAuthCubit>.value(value: getIt<AppAuthCubit>()),
            BlocProvider<ProjectsListCubit>.value(value: cubit),
          ],
          child: Sidebar(
            selectedIndex: 0,
            onItemSelected: (_) {},
            onProjectSelected: onProjectSelected,
          ),
        ),
      ),
    );
  }

  testWidgets('Sidebar displays dynamic project count and active projects', (
    WidgetTester tester,
  ) async {
    final projects = [
      const ProjectDto(
        id: 42,
        workspaceId: 1,
        name: 'Project Alpha',
        status: 'Active',
      ),
      const ProjectDto(
        id: 43,
        workspaceId: 1,
        name: 'Project Beta',
        status: 'Planning',
      ),
    ];
    when(
      () => mockProjectRepo.getProjects(
        1,
        status: any(named: 'status'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => projects);

    await projectsCubit.loadProjects(1);

    await tester.pumpWidget(buildTestWidget(cubit: projectsCubit));
    await tester.pumpAndSettle();

    // Verify Project count badge is '2'
    final projectsNavItem = find.widgetWithText(
      DesktopSidebarNavItem,
      'Projects',
    );
    expect(projectsNavItem, findsOneWidget);
    expect(
      find.descendant(of: projectsNavItem, matching: find.text('2')),
      findsOneWidget,
    );

    // Verify My Tasks does not have hardcoded badge '5'
    final tasksNavItem = find.widgetWithText(DesktopSidebarNavItem, 'My Tasks');
    expect(tasksNavItem, findsOneWidget);
    expect(
      find.descendant(of: tasksNavItem, matching: find.text('5')),
      findsNothing,
    );

    // Verify Active project Alpha appears
    expect(find.text('Project Alpha'), findsOneWidget);
  });

  testWidgets(
    'Tapping on a project quick link triggers onProjectSelected with projectId',
    (WidgetTester tester) async {
      final projects = [
        const ProjectDto(
          id: 99,
          workspaceId: 1,
          name: 'Realtime Core',
          status: 'Active',
        ),
      ];
      when(
        () => mockProjectRepo.getProjects(
          1,
          status: any(named: 'status'),
          forceRefresh: any(named: 'forceRefresh'),
        ),
      ).thenAnswer((_) async => projects);

      int? tappedProjectId;
      await projectsCubit.loadProjects(1);

      await tester.pumpWidget(
        buildTestWidget(
          cubit: projectsCubit,
          onProjectSelected: (id) => tappedProjectId = id,
        ),
      );
      await tester.pumpAndSettle();

      final link = find.widgetWithText(
        DesktopSidebarProjectQuickLink,
        'Realtime Core',
      );
      expect(link, findsOneWidget);

      await tester.tap(link);
      await tester.pumpAndSettle();

      expect(tappedProjectId, 99);
    },
  );

  testWidgets('Sidebar renders without projects cleanly', (
    WidgetTester tester,
  ) async {
    when(
      () => mockProjectRepo.getProjects(
        1,
        status: any(named: 'status'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => []);

    await projectsCubit.loadProjects(1);

    await tester.pumpWidget(buildTestWidget(cubit: projectsCubit));
    await tester.pumpAndSettle();

    // No quick links rendered
    expect(find.byType(DesktopSidebarProjectQuickLink), findsNothing);
  });
}
