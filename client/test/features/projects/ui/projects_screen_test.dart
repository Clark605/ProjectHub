import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/routes/route_names.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/projects/ui/projects_screen.dart';
import 'package:client/features/projects/ui/widgets/project_card.dart';
import 'package:client/features/projects/ui/widgets/projects_skeleton.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockProjectRepository projectRepo;
  late MockWorkspaceRepository workspaceRepo;
  late PrefsService prefs;
  late ProjectsListCubit projectsCubit;
  late WorkspaceContextCubit workspaceCubit;

  final sampleProjects = [
    const ProjectDto(
      id: 1,
      workspaceId: 1,
      name: 'Project One',
      description: 'First project',
      status: 'Planning',
    ),
    const ProjectDto(
      id: 2,
      workspaceId: 1,
      name: 'Project Two',
      description: 'Second project',
      status: 'Active',
    ),
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    prefs = PrefsService(sp);

    projectRepo = MockProjectRepository();
    when(
      () => projectRepo.getProjects(
        any(),
        status: any(named: 'status'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => List.from(sampleProjects));
    when(() => projectRepo.hasCachedProjects(any())).thenReturn(false);
    when(() => projectRepo.clearCache(any())).thenReturn(null);

    projectsCubit = ProjectsListCubit(projectRepo);

    workspaceRepo = createMockWorkspaceRepository(
      workspaces: [
        const WorkspaceDto(
          id: 1,
          name: 'Workspace One',
          description: 'Desc One',
          membership: WorkspaceMembershipDto(role: 'Owner'),
        ),
      ],
    );
    workspaceCubit = WorkspaceContextCubit(workspaceRepo, prefs);
    await workspaceCubit.loadWorkspaces();
  });

  tearDown(() {
    projectsCubit.close();
    workspaceCubit.close();
  });

  Widget createWidgetUnderTest({Map<String, WidgetBuilder>? routes}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: routes ?? {},
      home: MultiBlocProvider(
        providers: [
          BlocProvider<WorkspaceContextCubit>.value(value: workspaceCubit),
          BlocProvider<ProjectsListCubit>.value(value: projectsCubit),
        ],
        child: ProjectsScreen(cubit: projectsCubit),
      ),
    );
  }

  testWidgets('ProjectsScreen renders ProjectsSkeleton when loading', (
    tester,
  ) async {
    final completer = Completer<List<ProjectDto>>();
    when(
      () => projectRepo.getProjects(
        1,
        status: any(named: 'status'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(ProjectsSkeleton), findsOneWidget);

    completer.complete([]);
    await tester.pumpAndSettle();
  });

  testWidgets('ProjectsScreen renders ProjectCards when loaded', (
    tester,
  ) async {
    await projectsCubit.loadProjects(1);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(ProjectCard), findsNWidgets(2));
    expect(find.text('Project One'), findsOneWidget);
    expect(find.text('Project Two'), findsOneWidget);
  });

  testWidgets(
    'ProjectsScreen navigates to kanban when project card is tapped',
    (tester) async {
      dynamic pushedArguments;
      await projectsCubit.loadProjects(1);

      await tester.pumpWidget(
        createWidgetUnderTest(
          routes: {
            RouteNames.kanban: (context) {
              pushedArguments = ModalRoute.of(context)?.settings.arguments;
              return const Scaffold(body: Text('Kanban Destination'));
            },
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Project One'));
      await tester.pumpAndSettle();

      expect(find.text('Kanban Destination'), findsOneWidget);
      expect(pushedArguments, isA<ProjectDto>());
      expect((pushedArguments as ProjectDto).name, 'Project One');
    },
  );

  testWidgets('ProjectsScreen filters projects when status chip is tapped', (
    tester,
  ) async {
    await projectsCubit.loadProjects(1);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Tap "Active" chip
    await tester.tap(find.widgetWithText(ChoiceChip, 'Active'));
    await tester.pumpAndSettle();

    expect(find.text('Project Two'), findsOneWidget);
    expect(find.text('Project One'), findsNothing);
  });

  testWidgets('ProjectsScreen renders empty state when 0 projects exist', (
    tester,
  ) async {
    when(
      () => projectRepo.getProjects(
        1,
        status: any(named: 'status'),
        forceRefresh: any(named: 'forceRefresh'),
      ),
    ).thenAnswer((_) async => []);

    await projectsCubit.loadProjects(1);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(ProjectCard), findsNothing);
    expect(find.text('No projects found'), findsOneWidget);
  });
}
