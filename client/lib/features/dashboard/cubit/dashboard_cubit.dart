import 'package:injectable/injectable.dart';
import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/dashboard/cubit/dashboard_state.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/data/models/workspace_dashboard_dto.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

@injectable
class DashboardCubit extends SafeActionCubit<DashboardState> {
  final ActivityRepository _activityRepository;
  final ProjectRepository _projectRepository;
  final TaskRepository _taskRepository;
  final WorkspaceRepository _workspaceRepository;

  DashboardCubit(
    this._activityRepository,
    this._projectRepository,
    this._taskRepository,
    this._workspaceRepository,
  ) : super(const DashboardState(isLoading: true));

  static List<TaskDto> sortFocusTasks(List<TaskDto> tasks) {
    final nonDoneTasks = tasks.where((t) => t.status != 'Done').toList();
    nonDoneTasks.sort((a, b) {
      final pCompare = b.priorityEnum.index.compareTo(a.priorityEnum.index);
      if (pCompare != 0) return pCompare;
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }
      return 0;
    });
    return nonDoneTasks.take(5).toList();
  }

  Future<void> loadDashboard(int workspaceId) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    await safeExecute(
      () async {
        WorkspaceDashboardDto? serverDashboard;
        try {
          serverDashboard = await _workspaceRepository.getWorkspaceDashboard(
            workspaceId,
          );
        } catch (e, st) {
          AppLogger.error(
            'Failed to fetch server dashboard metrics for workspace $workspaceId: $e',
            tag: 'DashboardCubit',
            error: e,
            stackTrace: st,
          );
        }

        if (serverDashboard != null) {
          emit(
            DashboardState(
              isLoading: false,
              totalProjects: serverDashboard.activeProjectsCount,
              activeProjects: serverDashboard.activeProjectsCount,
              inProgressTasks: serverDashboard.inProgressTasksCount,
              urgentTasks: serverDashboard.urgentTasksCount,
              completedTasks: serverDashboard.completedTasksCount,
              focusTasks: serverDashboard.focusTasks,
              recentActivities: serverDashboard.recentActivities,
            ),
          );
          return;
        }

        // Fallback: If server dashboard endpoint fails, query repositories individually
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

        emit(
          DashboardState(
            isLoading: false,
            totalProjects: projects.length,
            activeProjects: activeProjects,
            inProgressTasks: inProgressTasks,
            urgentTasks: urgentTasks,
            completedTasks: doneTasks,
            focusTasks: sortFocusTasks(tasks),
            recentActivities: activities,
          ),
        );
      },
      onError: (msg) {
        emit(state.copyWith(isLoading: false, errorMessage: msg));
      },
      defaultErrorMessage: 'Failed to load dashboard. Please try again.',
      logTag: 'DashboardCubit',
    );
  }
}
