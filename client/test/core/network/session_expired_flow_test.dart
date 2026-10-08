import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/app.dart';
import 'package:client/core/cubit/app_settings_cubit.dart';
import 'package:client/core/cubit/app_settings_state.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/network/auth_interceptor.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/auth/cubit/login_cubit.dart';
import 'package:client/features/auth/cubit/login_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/user.dart';
import 'package:client/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:client/features/dashboard/data/models/workspace_dashboard_dto.dart';
import 'package:client/features/profile/cubit/profile_edit_cubit.dart';
import 'package:client/features/projects/cubit/projects_list_cubit.dart';
import 'package:client/features/tasks/cubit/my_tasks_cubit.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';

import '../../helpers/mock_repositories.dart';

class MockAppAuthCubit extends Mock implements AppAuthCubit {}
class MockWorkspaceContextCubit extends Mock implements WorkspaceContextCubit {}
class MockAppSettingsCubit extends Mock implements AppSettingsCubit {}
class MockLoginCubit extends Mock implements LoginCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAppAuthCubit mockAuthCubit;
  late MockWorkspaceContextCubit mockWorkspaceCubit;
  late MockAppSettingsCubit mockSettingsCubit;
  late MockAuthRepository mockAuthRepo;
  late MockActivityRepository mockActivityRepo;
  late MockProjectRepository mockProjectRepo;
  late MockTaskRepository mockTaskRepo;
  late MockWorkspaceRepository mockWorkspaceRepo;
  late MockLoginCubit mockLoginCubit;
  late DashboardCubit dashboardCubit;
  late ProjectsListCubit projectsListCubit;
  late MyTasksCubit myTasksCubit;
  late ProfileEditCubit profileEditCubit;

  setUp(() {
    getIt.reset();

    mockAuthCubit = MockAppAuthCubit();
    mockWorkspaceCubit = MockWorkspaceContextCubit();
    mockSettingsCubit = MockAppSettingsCubit();
    mockAuthRepo = MockAuthRepository();
    mockActivityRepo = MockActivityRepository();
    mockProjectRepo = MockProjectRepository();
    mockTaskRepo = MockTaskRepository();
    mockWorkspaceRepo = MockWorkspaceRepository();
    mockLoginCubit = MockLoginCubit();

    when(() => mockActivityRepo.getWorkspaceActivities(any(), limit: any(named: 'limit')))
        .thenAnswer((_) async => []);
    when(() => mockProjectRepo.getProjects(any(), status: any(named: 'status'), forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => []);
    when(() => mockTaskRepo.getMyTasks(any()))
        .thenAnswer((_) async => []);
    when(() => mockWorkspaceRepo.getWorkspaceDashboard(any()))
        .thenAnswer((_) async => const WorkspaceDashboardDto(
              activeProjectsCount: 0,
              inProgressTasksCount: 0,
              urgentTasksCount: 0,
              completedTasksCount: 0,
              overdueTasksCount: 0,
              dueThisWeekTasksCount: 0,
            ));

    dashboardCubit = DashboardCubit(
      mockActivityRepo,
      mockProjectRepo,
      mockTaskRepo,
      mockWorkspaceRepo,
    );
    projectsListCubit = ProjectsListCubit(mockProjectRepo);
    myTasksCubit = MyTasksCubit(mockTaskRepo);
    profileEditCubit = ProfileEditCubit(mockAuthRepo);

    when(() => mockAuthCubit.state).thenReturn(
      const AppAuthState.authenticated(User(id: '1', name: 'Clark', email: 'clark@example.com')),
    );
    when(() => mockAuthCubit.stream).thenAnswer(
      (_) => Stream.value(
        const AppAuthState.authenticated(User(id: '1', name: 'Clark', email: 'clark@example.com')),
      ),
    );
    when(() => mockAuthCubit.logout()).thenAnswer((_) async {});

    when(() => mockWorkspaceCubit.state).thenReturn(
      const WorkspaceContextState.initial(),
    );
    when(() => mockWorkspaceCubit.stream).thenAnswer(
      (_) => Stream.value(const WorkspaceContextState.initial()),
    );
    when(() => mockWorkspaceCubit.loadWorkspaces()).thenAnswer((_) async {});
    when(() => mockWorkspaceCubit.close()).thenAnswer((_) async {});

    when(() => mockLoginCubit.state).thenReturn(const LoginState.initial());
    when(() => mockLoginCubit.stream).thenAnswer((_) => Stream.value(const LoginState.initial()));
    when(() => mockLoginCubit.close()).thenAnswer((_) async {});
    when(() => mockAuthCubit.close()).thenAnswer((_) async {});
    when(() => mockSettingsCubit.close()).thenAnswer((_) async {});

    const defaultSettings = AppSettingsState(
      themeMode: ThemeMode.dark,
      locale: Locale('en'),
    );
    when(() => mockSettingsCubit.state).thenReturn(defaultSettings);
    when(() => mockSettingsCubit.stream).thenAnswer(
      (_) => Stream.value(defaultSettings),
    );

    getIt.registerSingleton<AppAuthCubit>(mockAuthCubit);
    getIt.registerSingleton<WorkspaceContextCubit>(mockWorkspaceCubit);
    getIt.registerSingleton<AppSettingsCubit>(mockSettingsCubit);
    getIt.registerSingleton<TaskRepository>(mockTaskRepo);
    getIt.registerSingleton<AuthRepository>(mockAuthRepo);
    getIt.registerFactory<DashboardCubit>(() => dashboardCubit);
    getIt.registerFactory<ProjectsListCubit>(() => projectsListCubit);
    getIt.registerFactory<MyTasksCubit>(() => myTasksCubit);
    getIt.registerFactory<ProfileEditCubit>(() => profileEditCubit);
    getIt.registerFactory<LoginCubit>(() => mockLoginCubit);

    AuthInterceptor.resetSessionExpiredThrottle();
  });

  tearDown(() {
    getIt.reset();
  });

  testWidgets('shows AlertDialog on AuthInterceptor session expiration and redirects on confirm', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProjectHubApp(initialRoute: RouteNames.dashboard),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // No dialog initially
    expect(find.byType(AlertDialog), findsNothing);

    // Trigger session expiration from interceptor
    AuthInterceptor.notifySessionExpired();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify session expired alert dialog appears
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Session Expired'), findsOneWidget);
    expect(
      find.text('Your session has expired. Please log in again to continue.'),
      findsOneWidget,
    );
    expect(find.text('Log In'), findsOneWidget);

    // Tap "Log In" button
    await tester.tap(find.text('Log In'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify logout was called on AppAuthCubit
    verify(() => mockAuthCubit.logout()).called(1);

    // Dialog is dismissed
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('does not show duplicate AlertDialog when session expired fires repeatedly', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProjectHubApp(initialRoute: RouteNames.dashboard),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Trigger session expiration twice in quick succession
    AuthInterceptor.notifySessionExpired();
    AuthInterceptor.resetSessionExpiredThrottle();
    AuthInterceptor.notifySessionExpired();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Exactly one AlertDialog must be shown
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
