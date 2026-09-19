import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/routes/route_names.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/projects/ui/projects_screen.dart';
import 'package:client/features/projects/ui/widgets/project_card.dart';
import 'package:client/features/projects/ui/widgets/projects_skeleton.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';
import 'package:client/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeWorkspaceRepo extends Fake implements WorkspaceRepository {
  List<WorkspaceDto> workspaces = [];

  @override
  void setActiveWorkspace(WorkspaceDto? workspace) {}

  @override
  Future<List<WorkspaceDto>> getWorkspaces({bool forceRefresh = false}) async =>
      workspaces;

  @override
  Future<WorkspaceDto> getWorkspace(
    int id, {
    bool forceRefresh = false,
  }) async => workspaces.firstWhere((w) => w.id == id);

  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request) async =>
      WorkspaceDto(
        id: 99,
        name: request.name,
        description: request.description,
        membership: const WorkspaceMembershipDto(role: 'Owner'),
      );

  @override
  Future<WorkspaceDto> updateWorkspace(
    int id,
    UpdateWorkspaceRequest request,
  ) async => WorkspaceDto(
    id: id,
    name: request.name,
    description: request.description,
    membership: const WorkspaceMembershipDto(role: 'Owner'),
  );

  @override
  Future<void> deleteWorkspace(int id) async {}

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
    userId: 'u_1',
    name: 'Member',
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

class _FakeProjectRepo implements ProjectRepository {
  List<ProjectDto> projects = [];
  Future<List<ProjectDto>>? delayedFuture;

  @override
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  }) async {
    if (delayedFuture != null) {
      return await delayedFuture!;
    }
    return List.of(projects);
  }

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async =>
      projects.firstWhere((p) => p.id == id);

  @override
  Future<ProjectDto> createProject(
    int workspaceId,
    CreateProjectRequest request,
  ) async {
    final created = ProjectDto(
      id: 99,
      workspaceId: workspaceId,
      name: request.name,
      description: request.description,
      status: 'Planning',
    );
    projects.add(created);
    return created;
  }

  @override
  Future<ProjectDto> updateProject(
    int id,
    UpdateProjectRequest request,
  ) async => projects.firstWhere((p) => p.id == id);

  @override
  Future<void> deleteProject(int id) async {
    projects.removeWhere((p) => p.id == id);
  }

  @override
  void clearCache([int? workspaceId]) {}

  @override
  bool hasCachedProjects(int workspaceId) => false;

  @override
  bool hasCachedProject(int id) => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeProjectRepo projectRepo;
  late _FakeWorkspaceRepo workspaceRepo;
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

    projectRepo = _FakeProjectRepo()..projects = List.from(sampleProjects);
    projectsCubit = ProjectsListCubit(projectRepo);

    workspaceRepo = _FakeWorkspaceRepo()
      ..workspaces = [
        const WorkspaceDto(
          id: 1,
          name: 'Workspace One',
          description: 'Desc One',
          membership: WorkspaceMembershipDto(role: 'Owner'),
        ),
      ];
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
    projectRepo.delayedFuture = completer.future;

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
    projectRepo.projects = [];
    await projectsCubit.loadProjects(1);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.byType(ProjectCard), findsNothing);
    expect(find.text('No projects found'), findsOneWidget);
  });
}
