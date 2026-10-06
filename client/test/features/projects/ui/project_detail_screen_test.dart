import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/auth/data/models/user.dart';
import 'package:client/features/projects/cubit/project_detail_cubit.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/ui/project_detail_screen.dart';
import 'package:client/features/projects/ui/widgets/project_danger_zone.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockProjectRepository projectRepo;
  late MockWorkspaceRepository workspaceRepo;
  late MockAuthRepository authRepo;
  late PrefsService prefs;
  late AppAuthCubit authCubit;
  late WorkspaceContextCubit workspaceCubit;
  late ProjectDetailCubit detailCubit;

  const sampleProject = ProjectDto(
    id: 1,
    workspaceId: 10,
    name: 'Test Project',
    description: 'A test project',
    status: 'Active',
    createdBy: 'u_creator',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    prefs = PrefsService(sp);

    authRepo = createMockAuthRepository();
    authCubit = AppAuthCubit(authRepo);

    workspaceRepo = createMockWorkspaceRepository(
      workspaces: [
        const WorkspaceDto(
          id: 10,
          name: 'Test WS',
          membership: WorkspaceMembershipDto(role: 'Member'),
        ),
      ],
    );
    workspaceCubit = WorkspaceContextCubit(workspaceRepo, prefs);

    projectRepo = createMockProjectRepository(project: sampleProject);
    detailCubit = ProjectDetailCubit(projectRepo);
  });

  tearDown(() {
    authCubit.close();
    workspaceCubit.close();
    detailCubit.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AppAuthCubit>.value(value: authCubit),
          BlocProvider<WorkspaceContextCubit>.value(value: workspaceCubit),
          BlocProvider<ProjectDetailCubit>.value(value: detailCubit),
        ],
        child: ProjectDetailScreen(projectId: 1, cubit: detailCubit),
      ),
    );
  }

  testWidgets('Owner has edit permissions and danger zone visible', (
    tester,
  ) async {
    authCubit.emit(
      const AppAuthState.authenticated(
        User(id: 'u_random', name: 'Owner User', email: 'owner@test.com'),
      ),
    );
    const ownerWs = WorkspaceDto(
      id: 10,
      name: 'WS',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    );
    when(() => workspaceRepo.getWorkspaces()).thenAnswer((_) async => [ownerWs]);
    when(
      () => workspaceRepo.getWorkspace(10, forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => ownerWs);
    await workspaceCubit.loadWorkspaces();

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Save'), findsOneWidget);
    expect(find.byType(ProjectDangerZone), findsOneWidget);
    expect(find.text('Read-only'), findsNothing);
  });

  testWidgets('Creator member has edit permissions and danger zone visible', (
    tester,
  ) async {
    authCubit.emit(
      const AppAuthState.authenticated(
        User(id: 'u_creator', name: 'Creator', email: 'creator@test.com'),
      ),
    );
    const memberWs = WorkspaceDto(
      id: 10,
      name: 'WS',
      membership: WorkspaceMembershipDto(role: 'Member'),
    );
    when(() => workspaceRepo.getWorkspaces()).thenAnswer((_) async => [memberWs]);
    when(
      () => workspaceRepo.getWorkspace(10, forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => memberWs);
    await workspaceCubit.loadWorkspaces();

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Save'), findsOneWidget);
    expect(find.byType(ProjectDangerZone), findsOneWidget);
    expect(find.text('Read-only'), findsNothing);
  });

  testWidgets('Non-creator member has read-only mode and no danger zone', (
    tester,
  ) async {
    authCubit.emit(
      const AppAuthState.authenticated(
        User(id: 'u_other', name: 'Other Member', email: 'other@test.com'),
      ),
    );
    const memberWs = WorkspaceDto(
      id: 10,
      name: 'WS',
      membership: WorkspaceMembershipDto(role: 'Member'),
    );
    when(() => workspaceRepo.getWorkspaces()).thenAnswer((_) async => [memberWs]);
    when(
      () => workspaceRepo.getWorkspace(10, forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => memberWs);
    await workspaceCubit.loadWorkspaces();

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Save'), findsNothing);
    expect(find.byType(ProjectDangerZone), findsNothing);
    expect(find.text('Read-only'), findsOneWidget);
  });
}
