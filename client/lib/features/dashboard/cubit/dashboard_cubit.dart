import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:client/features/dashboard/cubit/dashboard_state.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/task_repository.dart';

@injectable
class DashboardCubit extends Cubit<DashboardState> {
  final ActivityRepository _activityRepository;
  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;

  DashboardCubit(
    this._activityRepository,
    this._projectRepository,
    this._taskRepository,
  ) : super(const DashboardState(isLoading: true));

  Future<void> loadDashboard(int workspaceId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final results = await Future.wait([
        _projectRepository.getProjects(workspaceId),
        _taskRepository.getMyTasks(workspaceId),
        _activityRepository.getWorkspaceActivities(workspaceId, limit: 20),
      ]);

      final projects = results[0] as List<ProjectDto>;
      final tasks = results[1] as List<TaskDto>;
      final activities = results[2] as List<ActivityEventDto>;

      final activeProjects = projects
          .where((p) => p.status != 'Archived')
          .length;
      final inProgressTasks = tasks
          .where((t) => t.status == 'InProgress')
          .length;
      final urgentTasks = tasks
          .where((t) => t.priority == 'Urgent' && t.status != 'Done')
          .length;
      final doneTasks = tasks.where((t) => t.status == 'Done').length;
      final focusTasks = tasks
          .where((t) => t.status != 'Done')
          .take(3)
          .toList();

      emit(
        DashboardState(
          isLoading: false,
          totalProjects: projects.length,
          activeProjects: activeProjects,
          inProgressTasks: inProgressTasks,
          urgentBlockers: urgentTasks,
          completedTasks: doneTasks,
          focusTasks: focusTasks,
          recentActivities: activities,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
