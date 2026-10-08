import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:client/features/dashboard/cubit/dashboard_state.dart';
import 'package:client/features/dashboard/data/models/workspace_dashboard_dto.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  late MockActivityRepository mockActivityRepo;
  late MockProjectRepository mockProjectRepo;
  late MockTaskRepository mockTaskRepo;
  late MockWorkspaceRepository mockWorkspaceRepo;
  late DashboardCubit cubit;

  setUp(() {
    mockActivityRepo = MockActivityRepository();
    mockProjectRepo = MockProjectRepository();
    mockTaskRepo = MockTaskRepository();
    mockWorkspaceRepo = MockWorkspaceRepository();
    cubit = DashboardCubit(
      mockActivityRepo,
      mockProjectRepo,
      mockTaskRepo,
      mockWorkspaceRepo,
    );
  });

  tearDown(() {
    cubit.close();
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

      when(() => mockWorkspaceRepo.getWorkspaceDashboard(1))
          .thenAnswer((_) async => serverDto);

      await cubit.loadDashboard(1);

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.activeProjects, 5);
      expect(cubit.state.inProgressTasks, 8);
      expect(cubit.state.urgentTasks, 3);
      expect(cubit.state.completedTasks, 15);
      expect(cubit.state.focusTasks.length, 1);
      expect(cubit.state.focusTasks.first.title, 'Urgent Task');

      // Verifies that getMyTasks and getProjects were NOT called when server metrics succeeded
      verifyNever(() => mockTaskRepo.getMyTasks(any()));
      verifyNever(() => mockProjectRepo.getProjects(any()));
    });

    test('falls back to client derivation when server dashboard fails', () async {
      when(() => mockWorkspaceRepo.getWorkspaceDashboard(1))
          .thenThrow(Exception('Server metrics down'));
      when(() => mockProjectRepo.getProjects(1))
          .thenAnswer((_) async => const [
                ProjectDto(
                  id: 10,
                  workspaceId: 1,
                  name: 'Active Project',
                  status: 'Active',
                ),
              ]);
      when(() => mockTaskRepo.getMyTasks(1))
          .thenAnswer((_) async => const [
                TaskDto(
                  id: 10,
                  projectId: 10,
                  title: 'Task 1',
                  status: 'InProgress',
                  priority: 'Urgent',
                ),
                TaskDto(
                  id: 11,
                  projectId: 10,
                  title: 'Task 2',
                  status: 'Done',
                  priority: 'Low',
                ),
              ]);
      when(() => mockActivityRepo.getWorkspaceActivities(1, limit: 20))
          .thenAnswer((_) async => []);

      await cubit.loadDashboard(1);

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.activeProjects, 1);
      expect(cubit.state.inProgressTasks, 1);
      expect(cubit.state.urgentTasks, 1);
      expect(cubit.state.completedTasks, 1);
      expect(cubit.state.focusTasks.length, 1);
      expect(cubit.state.focusTasks.first.title, 'Task 1');
    });

    test('emits error message and isLoading: false when repository throws AppException', () async {
      when(() => mockWorkspaceRepo.getWorkspaceDashboard(1))
          .thenThrow(const UnauthorizedException(message: 'Authentication required'));
      when(() => mockProjectRepo.getProjects(1))
          .thenThrow(const UnauthorizedException(message: 'Authentication required'));
      when(() => mockTaskRepo.getMyTasks(1)).thenAnswer((_) async => []);
      when(() => mockActivityRepo.getWorkspaceActivities(1, limit: 20))
          .thenAnswer((_) async => []);

      await cubit.loadDashboard(1);

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, 'Authentication required');
    });

    test('emits sanitized error message and isLoading: false on generic exception', () async {
      when(() => mockWorkspaceRepo.getWorkspaceDashboard(1))
          .thenThrow(Exception('Server unreachable'));
      when(() => mockProjectRepo.getProjects(1))
          .thenThrow(Exception('Server unreachable'));
      when(() => mockTaskRepo.getMyTasks(1)).thenAnswer((_) async => []);
      when(() => mockActivityRepo.getWorkspaceActivities(1, limit: 20))
          .thenAnswer((_) async => []);

      await cubit.loadDashboard(1);

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, 'Failed to load dashboard. Please try again.');
    });
  });
}
