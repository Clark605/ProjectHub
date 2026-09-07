import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/core/storage/secure_storage_service.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';
import 'package:client/features/auth/data/models/user.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_nav_item.dart';
import 'package:client/features/shell/ui/widgets/desktop_sidebar_quick_links.dart';
import 'package:client/features/shell/ui/widgets/sidebar.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class _FakeAuthRepo implements AuthRepository {
  @override
  Future<User> getCurrentUser() async =>
      const User(name: 'Clark Kent', email: 'clark@example.com');
  @override
  Future<User> login(LoginDto dto) async =>
      const User(name: 'Clark Kent', email: 'clark@example.com');
  @override
  Future<void> logout() async {}
  @override
  Future<User> register(RegisterDto dto) async =>
      const User(name: 'Clark Kent', email: 'clark@example.com');
  @override
  Future<ForgotPasswordResponseDto> forgotPassword(
    ForgotPasswordDto dto,
  ) async => const ForgotPasswordResponseDto(message: 'ok');
  @override
  Future<void> resetPassword(ResetPasswordDto dto) async {}
}

class _FakeSecureStorage extends SecureStorageService {
  @override
  Future<String?> getAccessToken() async => 'fake-token';
  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {}
  @override
  Future<void> clearTokens() async {}
}

class _FakeProjectRepo implements ProjectRepository {
  List<ProjectDto> projectsToReturn = [];

  @override
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  }) async => projectsToReturn;

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async =>
      projectsToReturn.firstWhere((p) => p.id == id);

  @override
  Future<ProjectDto> createProject(int wsId, CreateProjectRequest req) async =>
      throw UnimplementedError();

  @override
  Future<ProjectDto> updateProject(int id, UpdateProjectRequest req) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteProject(int id) async {}

  @override
  void clearCache([int? workspaceId]) {}

  @override
  bool hasCachedProjects(int wsId) => false;

  @override
  bool hasCachedProject(int id) => false;
}

void main() {
  late _FakeProjectRepo fakeProjectRepo;
  late ProjectsListCubit projectsCubit;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final prefs = PrefsService(sp);
    getIt.registerSingleton<PrefsService>(prefs);

    final authCubit = AppAuthCubit(
      _FakeAuthRepo(),
      _FakeSecureStorage(),
      prefs,
    );
    getIt.registerSingleton<AppAuthCubit>(authCubit);

    fakeProjectRepo = _FakeProjectRepo();
    getIt.registerSingleton<ProjectRepository>(fakeProjectRepo);

    projectsCubit = ProjectsListCubit(fakeProjectRepo);
  });

  tearDown(() async {
    projectsCubit.close();
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
        body: BlocProvider<ProjectsListCubit>.value(
          value: cubit,
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
    fakeProjectRepo.projectsToReturn = [
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
      fakeProjectRepo.projectsToReturn = [
        const ProjectDto(
          id: 99,
          workspaceId: 1,
          name: 'Realtime Core',
          status: 'Active',
        ),
      ];

      int? tappedProjectId;
      await projectsCubit.loadProjects(1);

      await tester.pumpWidget(
        buildTestWidget(
          cubit: projectsCubit,
          onProjectSelected: (id) => tappedProjectId = id,
        ),
      );
      await tester.pumpAndSettle();

      final linkFinder = find.byType(DesktopSidebarProjectQuickLink);
      expect(linkFinder, findsOneWidget);

      await tester.tap(linkFinder);
      await tester.pumpAndSettle();

      expect(tappedProjectId, equals(99));
    },
  );

  testWidgets('Sidebar displays empty state when workspace has no projects', (
    WidgetTester tester,
  ) async {
    fakeProjectRepo.projectsToReturn = [];
    await projectsCubit.loadProjects(1);

    await tester.pumpWidget(buildTestWidget(cubit: projectsCubit));
    await tester.pumpAndSettle();

    expect(find.text('No projects yet'), findsOneWidget);
  });
}
