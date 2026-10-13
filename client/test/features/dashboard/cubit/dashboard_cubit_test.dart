import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/errors/app_failure.dart';
import 'package:client/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:client/features/dashboard/cubit/dashboard_state.dart';
import 'package:client/features/dashboard/data/models/workspace_dashboard_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  late MockWorkspaceRepository mockWorkspaceRepo;
  late DashboardCubit cubit;

  setUp(() {
    mockWorkspaceRepo = MockWorkspaceRepository();
    cubit = DashboardCubit(mockWorkspaceRepo);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('DashboardCubit', () {
    test('initial state has isLoading: true', () {
      expect(cubit.state, const DashboardState(isLoading: true));
    });

    test('loads dashboard using server dashboard data directly', () async {
      const serverDto = WorkspaceDashboardDto(
        activeProjectsCount: 5,
        inProgressTasksCount: 8,
        urgentTasksCount: 3,
        completedTasksCount: 15,
        overdueTasksCount: 2,
        dueThisWeekTasksCount: 4,
        focusTasks: [
          TaskDto(
            id: 1,
            projectId: 10,
            title: 'Urgent Task',
            priority: 'Urgent',
            status: 'InProgress',
          ),
        ],
        recentActivities: [],
      );

      when(
        () => mockWorkspaceRepo.getWorkspaceDashboard(1),
      ).thenAnswer((_) async => serverDto);

      await cubit.loadDashboard(1);

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.activeProjects, 5);
      expect(cubit.state.inProgressTasks, 8);
      expect(cubit.state.urgentTasks, 3);
      expect(cubit.state.completedTasks, 15);
      expect(cubit.state.focusTasks.length, 1);
      expect(cubit.state.focusTasks.first.title, 'Urgent Task');
    });

    test(
      'emits AppFailure state directly when server dashboard fails (no client recompute)',
      () async {
        when(
          () => mockWorkspaceRepo.getWorkspaceDashboard(1),
        ).thenThrow(Exception('Server metrics down'));

        await cubit.loadDashboard(1);

        expect(cubit.state.isLoading, isFalse);
        expect(
          cubit.state.failure,
          const AppFailure(kind: FailureKind.unknown, isUserSafe: false),
        );
        expect(cubit.state.activeProjects, 0);
        expect(cubit.state.focusTasks, isEmpty);
      },
    );

    test(
      'emits AppFailure and isLoading: false when repository throws AppException',
      () async {
        when(() => mockWorkspaceRepo.getWorkspaceDashboard(1)).thenThrow(
          const UnauthorizedException(
            message: 'Authentication required',
            serverMessage: 'Authentication required',
          ),
        );

        await cubit.loadDashboard(1);

        expect(cubit.state.isLoading, isFalse);
        expect(
          cubit.state.failure,
          const AppFailure(
            kind: FailureKind.unauthorized,
            serverMessage: 'Authentication required',
            isUserSafe: true,
          ),
        );
      },
    );

    test(
      'DashboardState.copyWith keeps failure when omitted and clears it when clearFailure is true',
      () {
        const failure = AppFailure(kind: FailureKind.server, isUserSafe: false);
        const initial = DashboardState(activeProjects: 2, failure: failure);

        final preserved = initial.copyWith(activeProjects: 3);
        expect(preserved.activeProjects, 3);
        expect(preserved.failure, failure);

        final cleared = preserved.copyWith(clearFailure: true);
        expect(cleared.failure, isNull);
      },
    );
  });
}
