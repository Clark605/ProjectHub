import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/user.dart';
import 'package:client/features/dashboard/ui/dashboard_screen.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';

import 'package:client/features/tasks/ui/my_tasks_screen.dart';
import 'package:client/features/shell/ui/main_shell_screen.dart';
import 'package:client/features/shell/ui/widgets/sidebar.dart';
import 'package:client/features/shell/ui/widgets/mobile_bottom_nav.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';
import 'package:client/features/workspaces/ui/widgets/quick_start_dialog.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class _FakeAuthRepository extends Fake implements AuthRepository {
  final _authStateController = StreamController<User?>.broadcast();
  @override
  Stream<User?> get authStateChanges => _authStateController.stream;
  @override
  Future<User?> restoreSession() async =>
      const User(name: 'Test Clark', email: 'clark@example.com');
  @override
  Future<User> getCurrentUser() async =>
      const User(name: 'Test Clark', email: 'clark@example.com');
}

class _FakeWorkspaceRepository extends Fake implements WorkspaceRepository {
  List<WorkspaceDto> workspaces = [
    const WorkspaceDto(
      id: 1,
      name: 'Engineering Team',
      description: 'Core dev',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    ),
  ];

  @override
  void setActiveWorkspace(WorkspaceDto? workspace) {}

  @override
  Future<List<WorkspaceDto>> getWorkspaces() async => workspaces;

  @override
  Future<WorkspaceDto> getWorkspace(
    int id, {
    bool forceRefresh = false,
  }) async => workspaces.firstWhere(
    (w) => w.id == id,
    orElse: () => const WorkspaceDto(
      id: 1,
      name: 'Engineering Team',
      description: 'Core dev',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    ),
  );

  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request) async =>
      WorkspaceDto(
        id: 2,
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
    userId: 'u_new',
    name: 'New Member',
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

class _FakeProjectRepository implements ProjectRepository {
  List<ProjectDto> projects = [];

  @override
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  }) async => projects;

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async =>
      const ProjectDto(id: 1, name: 'Project 1', workspaceId: 1);

  @override
  Future<ProjectDto> createProject(
    int workspaceId,
    CreateProjectRequest request,
  ) async => ProjectDto(
    id: 99,
    name: request.name,
    description: request.description,
    workspaceId: workspaceId,
  );

  @override
  Future<ProjectDto> updateProject(
    int id,
    UpdateProjectRequest request,
  ) async => ProjectDto(
    id: id,
    name: request.name,
    description: request.description,
    workspaceId: 1,
  );

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
  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final prefs = PrefsService(sp);
    getIt.registerSingleton<PrefsService>(prefs);

    final authRepo = _FakeAuthRepository();
    final authCubit = AppAuthCubit(authRepo);
    getIt.registerSingleton<AppAuthCubit>(authCubit);

    final workspaceRepo = _FakeWorkspaceRepository();
    final workspaceCubit = WorkspaceContextCubit(workspaceRepo, prefs);
    getIt.registerSingleton<WorkspaceContextCubit>(workspaceCubit);

    final projectRepo = _FakeProjectRepository();
    getIt.registerSingleton<ProjectRepository>(projectRepo);
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('MainShellScreen renders Desktop layout with DesktopSidebar', (
    WidgetTester tester,
  ) async {
    // Set desktop screen size (1440x900)
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

    // Verify DesktopSidebar & DashboardScreen render
    expect(find.byType(Sidebar), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('MainShellScreen renders Mobile layout with MobileBottomNav', (
    WidgetTester tester,
  ) async {
    // Set mobile screen size (400x800)
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

    // Verify MobileBottomNav & DashboardScreen render
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

    // Tap My Tasks tab in sidebar
    await tester.tap(find.text('My Tasks').first);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MyTasksScreen), findsOneWidget);
  });

  testWidgets(
    'MainShellScreen renders "Create Workspace" and no role badge when user has no workspaces',
    (WidgetTester tester) async {
      final sp = await SharedPreferences.getInstance();
      final prefs = PrefsService(sp);
      final emptyRepo = _FakeWorkspaceRepository()..workspaces = [];
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

      // Top bar displays "Create Workspace"
      expect(find.text('Create Workspace'), findsWidgets);
      // No role badge exists ("Owner" or "Member")
      expect(find.text('Owner'), findsNothing);
      expect(find.text('Member'), findsNothing);
      // Workspace settings icon is not displayed
      expect(find.byIcon(Icons.settings_outlined), findsNothing);
    },
  );

  testWidgets(
    'Tapping "Create Workspace" in ShellTopBar when user has no workspaces opens QuickStartDialog',
    (WidgetTester tester) async {
      final sp = await SharedPreferences.getInstance();
      final prefs = PrefsService(sp);
      final emptyRepo = _FakeWorkspaceRepository()..workspaces = [];
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

      // Pop dialog
      final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
      nav.pop();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(QuickStartDialog), findsNothing);

      // Tap "Create Workspace" button in top bar
      await tester.tap(find.text('Create Workspace').first);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(QuickStartDialog), findsOneWidget);
    },
  );
}
