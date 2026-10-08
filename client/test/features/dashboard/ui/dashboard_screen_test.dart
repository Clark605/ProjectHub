import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/widgets/app_error_state.dart';
import 'package:client/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:client/features/dashboard/data/models/workspace_dashboard_dto.dart';
import 'package:client/features/dashboard/ui/dashboard_screen.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_state.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import '../../../helpers/mock_repositories.dart';

class MockWorkspaceContextCubit extends Mock implements WorkspaceContextCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockActivityRepository mockActivityRepo;
  late MockProjectRepository mockProjectRepo;
  late MockTaskRepository mockTaskRepo;
  late MockWorkspaceRepository mockWorkspaceRepo;
  late MockWorkspaceContextCubit mockWorkspaceCubit;
  late DashboardCubit dashboardCubit;

  const testWorkspace = WorkspaceDto(
    id: 31,
    name: 'google workspace',
    description: 'Test WS',
    membership: WorkspaceMembershipDto(role: 'Owner'),
  );

  setUp(() {
    mockActivityRepo = MockActivityRepository();
    mockProjectRepo = MockProjectRepository();
    mockTaskRepo = MockTaskRepository();
    mockWorkspaceRepo = MockWorkspaceRepository();
    mockWorkspaceCubit = MockWorkspaceContextCubit();

    when(() => mockWorkspaceRepo.getWorkspaceDashboard(any())).thenAnswer(
      (_) async => const WorkspaceDashboardDto(
        activeProjectsCount: 1,
        inProgressTasksCount: 0,
        urgentTasksCount: 0,
        completedTasksCount: 0,
        overdueTasksCount: 0,
        dueThisWeekTasksCount: 0,
      ),
    );

    when(() => mockWorkspaceCubit.state).thenReturn(
      const WorkspaceContextState.loaded(
        workspaces: [testWorkspace],
        activeWorkspace: testWorkspace,
      ),
    );
    when(() => mockWorkspaceCubit.stream).thenAnswer(
      (_) => Stream.value(
        const WorkspaceContextState.loaded(
          workspaces: [testWorkspace],
          activeWorkspace: testWorkspace,
        ),
      ),
    );

    dashboardCubit = DashboardCubit(
      mockActivityRepo,
      mockProjectRepo,
      mockTaskRepo,
      mockWorkspaceRepo,
    );
  });

  tearDown(() {
    dashboardCubit.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<WorkspaceContextCubit>.value(
              value: mockWorkspaceCubit,
            ),
            BlocProvider<DashboardCubit>.value(value: dashboardCubit),
          ],
          child: const DashboardScreen(),
        ),
      ),
    );
  }

  group('DashboardScreen error handling', () {
    testWidgets(
      'displays AppErrorState when loading fails (eliminating silent error)',
      (tester) async {
        when(() => mockWorkspaceRepo.getWorkspaceDashboard(31)).thenThrow(
          const UnauthorizedException(message: 'Authentication required'),
        );
        when(() => mockProjectRepo.getProjects(31)).thenThrow(
          const UnauthorizedException(message: 'Authentication required'),
        );
        when(() => mockTaskRepo.getMyTasks(31)).thenAnswer((_) async => []);
        when(
          () => mockActivityRepo.getWorkspaceActivities(31, limit: 20),
        ).thenAnswer((_) async => []);

        await dashboardCubit.loadDashboard(31);

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.byType(AppErrorState), findsOneWidget);
        expect(find.textContaining('Authentication required'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets('tapping retry re-triggers loadDashboard', (tester) async {
      when(
        () => mockWorkspaceRepo.getWorkspaceDashboard(31),
      ).thenThrow(const ServerException(message: 'Connection failure'));
      when(
        () => mockProjectRepo.getProjects(31),
      ).thenThrow(const ServerException(message: 'Connection failure'));
      when(() => mockTaskRepo.getMyTasks(31)).thenAnswer((_) async => []);
      when(
        () => mockActivityRepo.getWorkspaceActivities(31, limit: 20),
      ).thenAnswer((_) async => []);

      await dashboardCubit.loadDashboard(31);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorState), findsOneWidget);

      // Now mock successful response on retry
      when(() => mockWorkspaceRepo.getWorkspaceDashboard(31)).thenAnswer(
        (_) async => const WorkspaceDashboardDto(
          activeProjectsCount: 1,
          inProgressTasksCount: 0,
          urgentTasksCount: 0,
          completedTasksCount: 0,
          overdueTasksCount: 0,
          dueThisWeekTasksCount: 0,
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      verify(
        () => mockWorkspaceRepo.getWorkspaceDashboard(31),
      ).called(greaterThanOrEqualTo(2));
    });
  });
}
