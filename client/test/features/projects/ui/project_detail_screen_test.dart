import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/user.dart';
import 'package:client/features/projects/cubit/project_detail_cubit.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/projects/ui/project_detail_screen.dart';
import 'package:client/features/projects/ui/widgets/project_danger_zone.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';
import 'package:client/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository extends Fake implements AuthRepository {
  final _authStateController = StreamController<User?>.broadcast();
  @override
  Stream<User?> get authStateChanges => _authStateController.stream;
  @override
  Future<User?> restoreSession() async =>
      const User(id: 'u1', name: 'User 1', email: 'u1@test.com');
  @override
  Future<User> getCurrentUser() async =>
      const User(id: 'u1', name: 'User 1', email: 'u1@test.com');
}


class _FakeWorkspaceRepo implements WorkspaceRepository {
  WorkspaceDto workspace = const WorkspaceDto(
    id: 10,
    name: 'Test WS',
    membership: WorkspaceMembershipDto(role: 'Member'),
  );

  @override
  Future<List<WorkspaceDto>> getWorkspaces({bool forceRefresh = false}) async =>
      [workspace];

  @override
  Future<WorkspaceDto> getWorkspace(
    int id, {
    bool forceRefresh = false,
  }) async => workspace;
  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request) async =>
      workspace;
  @override
  Future<WorkspaceDto> updateWorkspace(
    int id,
    UpdateWorkspaceRequest request,
  ) async => workspace;
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
    userId: 'u',
    name: 'M',
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
  ProjectDto project = const ProjectDto(
    id: 1,
    workspaceId: 10,
    name: 'Test Project',
    description: 'A test project',
    status: 'Active',
    createdBy: 'u_creator',
  );

  @override
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  }) async => [project];

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async =>
      project;

  @override
  Future<ProjectDto> createProject(
    int workspaceId,
    CreateProjectRequest request,
  ) async => project;

  @override
  Future<ProjectDto> updateProject(
    int id,
    UpdateProjectRequest request,
  ) async => project;

  @override
  Future<void> deleteProject(int id) async {}

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
  late AppAuthCubit authCubit;
  late WorkspaceContextCubit workspaceCubit;
  late ProjectDetailCubit detailCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    prefs = PrefsService(sp);

    authCubit = AppAuthCubit(_FakeAuthRepository());
    workspaceRepo = _FakeWorkspaceRepo();
    workspaceCubit = WorkspaceContextCubit(workspaceRepo, prefs);
    projectRepo = _FakeProjectRepo();
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
    workspaceRepo.workspace = const WorkspaceDto(
      id: 10,
      name: 'WS',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    );
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
    workspaceRepo.workspace = const WorkspaceDto(
      id: 10,
      name: 'WS',
      membership: WorkspaceMembershipDto(role: 'Member'),
    );
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
    workspaceRepo.workspace = const WorkspaceDto(
      id: 10,
      name: 'WS',
      membership: WorkspaceMembershipDto(role: 'Member'),
    );
    await workspaceCubit.loadWorkspaces();

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Save'), findsNothing);
    expect(find.byType(ProjectDangerZone), findsNothing);
    expect(find.text('Read-only'), findsOneWidget);
  });
}
