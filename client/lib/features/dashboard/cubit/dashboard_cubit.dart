import 'package:injectable/injectable.dart';
import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/dashboard/cubit/dashboard_state.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

@injectable
class DashboardCubit extends SafeActionCubit<DashboardState> {
  final WorkspaceRepository _workspaceRepository;

  DashboardCubit(this._workspaceRepository)
    : super(const DashboardState(isLoading: true));

  Future<void> loadDashboard(int workspaceId) async {
    emit(state.copyWith(isLoading: true, failure: null));

    await safeExecute(
      () async {
        final serverDashboard = await _workspaceRepository
            .getWorkspaceDashboard(workspaceId);

        emit(
          DashboardState(
            isLoading: false,
            activeProjects: serverDashboard.activeProjectsCount,
            inProgressTasks: serverDashboard.inProgressTasksCount,
            urgentTasks: serverDashboard.urgentTasksCount,
            completedTasks: serverDashboard.completedTasksCount,
            focusTasks: serverDashboard.focusTasks,
            recentActivities: serverDashboard.recentActivities,
          ),
        );
      },
      onFailure: (failure) {
        emit(state.copyWith(isLoading: false, failure: failure));
      },
      logTag: 'DashboardCubit',
    );
  }
}
