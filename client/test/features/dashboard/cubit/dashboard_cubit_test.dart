import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:client/features/dashboard/cubit/dashboard_state.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  late MockActivityRepository mockActivityRepo;
  late MockProjectRepository mockProjectRepo;
  late MockTaskRepository mockTaskRepo;
  late DashboardCubit cubit;

  setUp(() {
    mockActivityRepo = MockActivityRepository();
    mockProjectRepo = MockProjectRepository();
    mockTaskRepo = MockTaskRepository();
    cubit = DashboardCubit(
      mockActivityRepo,
      mockProjectRepo,
      mockTaskRepo,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('DashboardCubit', () {
    test('initial state has isLoading: true', () {
      expect(cubit.state, const DashboardState(isLoading: true));
    });

    test('emits error message and isLoading: false when repository throws AppException', () async {
      when(() => mockProjectRepo.getProjects(1))
          .thenThrow(const UnauthorizedException(message: 'Authentication required'));
      when(() => mockTaskRepo.getMyTasks(1)).thenAnswer((_) async => []);
      when(() => mockActivityRepo.getWorkspaceActivities(1, limit: 20))
          .thenAnswer((_) async => []);

      await cubit.loadDashboard(1);

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, 'Authentication required');
    });

    test('emits error message and isLoading: false on generic exception', () async {
      when(() => mockProjectRepo.getProjects(1))
          .thenThrow(Exception('Server unreachable'));
      when(() => mockTaskRepo.getMyTasks(1)).thenAnswer((_) async => []);
      when(() => mockActivityRepo.getWorkspaceActivities(1, limit: 20))
          .thenAnswer((_) async => []);

      await cubit.loadDashboard(1);

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.errorMessage, contains('Server unreachable'));
    });
  });
}
