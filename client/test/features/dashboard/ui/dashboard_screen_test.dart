import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/widgets/app_error_state.dart';
import 'package:client/features/dashboard/cubit/dashboard_cubit.dart';
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
    mockWorkspaceCubit = MockWorkspaceContextCubit();

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
            BlocProvider<WorkspaceContextCubit>.value(value: mockWorkspaceCubit),
            BlocProvider<DashboardCubit>.value(value: dashboardCubit),
          ],
          child: DashboardScreen(cubit: dashboardCubit),
        ),
      ),
    );
  }

  group('DashboardScreen error handling', () {
    testWidgets('displays AppErrorState when loading fails (eliminating silent error)', (
      tester,
    ) async {
      when(() => mockProjectRepo.getProjects(31))
          .thenThrow(Exception('Authentication required'));
      when(() => mockTaskRepo.getMyTasks(31)).thenAnswer((_) async => []);
      when(() => mockActivityRepo.getWorkspaceActivities(31, limit: 20))
          .thenAnswer((_) async => []);

      await dashboardCubit.loadDashboard(31);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorState), findsOneWidget);
      expect(find.textContaining('Authentication required'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('tapping retry re-triggers loadDashboard', (tester) async {
      when(() => mockProjectRepo.getProjects(31))
          .thenThrow(Exception('Connection failure'));
      when(() => mockTaskRepo.getMyTasks(31)).thenAnswer((_) async => []);
      when(() => mockActivityRepo.getWorkspaceActivities(31, limit: 20))
          .thenAnswer((_) async => []);

      await dashboardCubit.loadDashboard(31);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(AppErrorState), findsOneWidget);

      // Now mock successful response on retry
      when(() => mockProjectRepo.getProjects(31)).thenAnswer((_) async => []);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      verify(() => mockProjectRepo.getProjects(31)).called(greaterThanOrEqualTo(2));
    });
  });
}
