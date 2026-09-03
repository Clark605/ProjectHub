import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/core/storage/secure_storage_service.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';
import 'package:client/features/auth/data/models/user.dart';
import 'package:client/features/projects/ui/projects_screen.dart';
import 'package:client/features/tasks/ui/my_tasks_screen.dart';
import 'package:client/features/shell/ui/main_shell_screen.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar.dart';
import 'package:client/features/shell/ui/widgets/mobile_bottom_nav.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<User> login(LoginDto dto) async =>
      const User(name: 'Test Clark', email: 'clark@example.com');

  @override
  Future<User> register(RegisterDto dto) async =>
      const User(name: 'Test Clark', email: 'clark@example.com');

  @override
  Future<User> getCurrentUser() async =>
      const User(name: 'Test Clark', email: 'clark@example.com');

  @override
  Future<void> logout() async {}

  @override
  Future<ForgotPasswordResponseDto> forgotPassword(
    ForgotPasswordDto dto,
  ) async => const ForgotPasswordResponseDto(message: 'Reset sent');

  @override
  Future<void> resetPassword(ResetPasswordDto dto) async {}
}

class _FakeSecureStorageService extends SecureStorageService {
  @override
  Future<String?> getAccessToken() async => 'fake-token';
  @override
  Future<String?> getRefreshToken() async => 'fake-refresh';
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
  @override
  Future<void> clearTokens() async {}
}

class _FakeWorkspaceRepository implements WorkspaceRepository {
  @override
  Future<List<WorkspaceDto>> getWorkspaces() async => [
    const WorkspaceDto(
      id: 1,
      name: 'Engineering Team',
      description: 'Core dev',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    ),
  ];

  @override
  Future<WorkspaceDto> getWorkspace(int id) async => const WorkspaceDto(
    id: 1,
    name: 'Engineering Team',
    description: 'Core dev',
    membership: WorkspaceMembershipDto(role: 'Owner'),
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
  ) async =>
      WorkspaceDto(
        id: id,
        name: request.name,
        description: request.description,
        membership: const WorkspaceMembershipDto(role: 'Owner'),
      );

  @override
  Future<void> deleteWorkspace(int id) async {}

  @override
  Future<List<MemberDto>> getMembers(int workspaceId) async => [];

  @override
  Future<MemberDto> addMember(
    int workspaceId,
    AddMemberRequest request,
  ) async =>
      MemberDto(
        userId: 'u_new',
        name: 'New Member',
        email: request.email,
        role: 'Member',
        joinedAt: DateTime.now(),
      );

  @override
  Future<void> removeMember(int workspaceId, String userId) async {}
}

void main() {
  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final prefs = PrefsService(sp);
    getIt.registerSingleton<PrefsService>(prefs);

    final authRepo = _FakeAuthRepository();
    final secureStorage = _FakeSecureStorageService();
    final authCubit = AppAuthCubit(authRepo, secureStorage, prefs);
    getIt.registerSingleton<AppAuthCubit>(authCubit);

    final workspaceRepo = _FakeWorkspaceRepository();
    final workspaceCubit = WorkspaceContextCubit(workspaceRepo, prefs);
    getIt.registerSingleton<WorkspaceContextCubit>(workspaceCubit);
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
      const MaterialApp(home: MainShellScreen(initialIndex: 0)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify DesktopSidebar & ProjectsScreen render
    expect(find.byType(DesktopSidebar), findsOneWidget);
    expect(find.byType(ProjectsScreen), findsOneWidget);
  });

  testWidgets('MainShellScreen renders Mobile layout with MobileBottomNav', (
    WidgetTester tester,
  ) async {
    // Set mobile screen size (400x800)
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(home: MainShellScreen(initialIndex: 0)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify MobileBottomNav & ProjectsScreen render
    expect(find.byType(MobileBottomNav), findsOneWidget);
    expect(find.byType(ProjectsScreen), findsOneWidget);
  });

  testWidgets('MainShellScreen switches to My Tasks tab on selection', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(home: MainShellScreen(initialIndex: 0)),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ProjectsScreen), findsOneWidget);

    // Tap My Tasks tab in sidebar
    await tester.tap(find.text('My Tasks').first);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(MyTasksScreen), findsOneWidget);
  });
}
