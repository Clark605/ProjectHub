import 'dart:async';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/network/signalr_service.dart';
import 'package:client/core/storage/secure_storage_service.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/user.dart';
import 'package:client/features/comments/data/comment_repository.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/dashboard/data/models/workspace_dashboard_dto.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/ai_task_repository.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockWorkspaceRepository extends Mock implements WorkspaceRepository {}

class MockProjectRepository extends Mock implements ProjectRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class MockActivityRepository extends Mock implements ActivityRepository {}

class MockCommentRepository extends Mock implements CommentRepository {}

class MockAiTaskRepository extends Mock implements AiTaskRepository {}

class MockSignalRService extends Mock implements SignalRService {}

/// Helper to create a configured [MockSignalRService] with sensible test defaults.
MockSignalRService createMockSignalRService() {
  final service = MockSignalRService();
  when(() => service.presenceChanged).thenAnswer((_) => const Stream.empty());
  when(() => service.realtimeStatus).thenAnswer((_) => const Stream.empty());
  when(() => service.currentStatus).thenReturn(RealtimeStatus.disconnected);
  when(() => service.taskCreated).thenAnswer((_) => const Stream.empty());
  when(() => service.taskUpdated).thenAnswer((_) => const Stream.empty());
  when(() => service.taskDeleted).thenAnswer((_) => const Stream.empty());
  when(() => service.taskStatusChanged).thenAnswer((_) => const Stream.empty());
  when(() => service.taskAssigned).thenAnswer((_) => const Stream.empty());
  when(() => service.commentAdded).thenAnswer((_) => const Stream.empty());
  when(() => service.commentDeleted).thenAnswer((_) => const Stream.empty());
  when(() => service.reconnected).thenAnswer((_) => const Stream.empty());
  when(() => service.joinWorkspace(any())).thenAnswer((_) async {});
  when(() => service.leaveWorkspace(any())).thenAnswer((_) async {});
  return service;
}

class MockSecureStorageService extends Mock implements SecureStorageService {}

/// Helper to create a configured [MockAuthRepository] with sensible test defaults.
MockAuthRepository createMockAuthRepository({
  User user = const User(name: 'Test Clark', email: 'clark@example.com'),
}) {
  final repo = MockAuthRepository();
  final controller = StreamController<User?>.broadcast();
  when(() => repo.authStateChanges).thenAnswer((_) => controller.stream);
  when(() => repo.restoreSession()).thenAnswer((_) async => user);
  when(() => repo.getCurrentUser()).thenAnswer((_) async => user);
  when(() => repo.logout()).thenAnswer((_) async {
    controller.add(null);
  });
  return repo;
}

/// Helper to create a configured [MockWorkspaceRepository] with sensible test defaults.
MockWorkspaceRepository createMockWorkspaceRepository({
  List<WorkspaceDto>? workspaces,
  WorkspaceDto? activeWorkspace,
}) {
  final repo = MockWorkspaceRepository();
  final list =
      workspaces ??
      [
        const WorkspaceDto(
          id: 1,
          name: 'Engineering Team',
          description: 'Core dev',
          membership: WorkspaceMembershipDto(role: 'Owner'),
        ),
      ];
  final active = activeWorkspace ?? (list.isNotEmpty ? list.first : null);

  when(() => repo.activeWorkspace).thenReturn(active);
  when(
    () => repo.activeWorkspaceChanges,
  ).thenAnswer((_) => const Stream.empty());
  when(() => repo.setActiveWorkspace(any())).thenReturn(null);
  when(() => repo.getWorkspaces()).thenAnswer((_) async => list);
  when(
    () => repo.getWorkspace(any(), forceRefresh: any(named: 'forceRefresh')),
  ).thenAnswer((inv) async {
    final id = inv.positionalArguments[0] as int;
    return list.firstWhere((w) => w.id == id, orElse: () => list.first);
  });
  when(
    () => repo.getMembers(any(), forceRefresh: any(named: 'forceRefresh')),
  ).thenAnswer((_) async => []);
  when(() => repo.getWorkspaceDashboard(any())).thenAnswer(
    (_) async => const WorkspaceDashboardDto(
      activeProjectsCount: 1,
      inProgressTasksCount: 0,
      urgentTasksCount: 0,
      completedTasksCount: 0,
      overdueTasksCount: 0,
      dueThisWeekTasksCount: 0,
    ),
  );
  when(() => repo.hasCachedSettings(any())).thenReturn(false);
  when(() => repo.clearCache(any())).thenReturn(null);

  return repo;
}

/// Helper to create a configured [MockProjectRepository] with sensible test defaults.
MockProjectRepository createMockProjectRepository({
  List<ProjectDto>? projects,
  ProjectDto? project,
}) {
  final repo = MockProjectRepository();
  final defaultProj =
      project ?? const ProjectDto(id: 1, name: 'Project 1', workspaceId: 1);
  final list = projects ?? [defaultProj];

  when(
    () => repo.getProjects(
      any(),
      status: any(named: 'status'),
      forceRefresh: any(named: 'forceRefresh'),
    ),
  ).thenAnswer((_) async => list);
  when(
    () => repo.getProject(any(), forceRefresh: any(named: 'forceRefresh')),
  ).thenAnswer((inv) async {
    final id = inv.positionalArguments[0] as int;
    return list.firstWhere((p) => p.id == id, orElse: () => defaultProj);
  });
  when(() => repo.hasCachedProjects(any())).thenReturn(false);
  when(() => repo.hasCachedProject(any())).thenReturn(false);
  when(() => repo.clearCache(any())).thenReturn(null);

  return repo;
}

/// Helper to create a configured [MockTaskRepository] with sensible test defaults.
MockTaskRepository createMockTaskRepository({List<TaskDto>? tasks}) {
  final repo = MockTaskRepository();
  final list = tasks ?? [];

  when(
    () => repo.getTasksByProject(
      any(),
      status: any(named: 'status'),
      assigneeId: any(named: 'assigneeId'),
      priority: any(named: 'priority'),
      forceRefresh: any(named: 'forceRefresh'),
    ),
  ).thenAnswer((_) async => list);
  when(
    () => repo.getMyTasks(any(), forceRefresh: any(named: 'forceRefresh')),
  ).thenAnswer((_) async => list);
  when(
    () => repo.getTask(any(), forceRefresh: any(named: 'forceRefresh')),
  ).thenAnswer((inv) async {
    final id = inv.positionalArguments[0] as int;
    return list.firstWhere(
      (t) => t.id == id,
      orElse: () => TaskDto(id: id, projectId: 1, title: 'Task $id'),
    );
  });
  when(() => repo.hasCachedTasks(any())).thenReturn(false);
  when(() => repo.clearCache(any())).thenReturn(null);

  return repo;
}

/// Helper to create a configured [MockActivityRepository] with sensible test defaults.
MockActivityRepository createMockActivityRepository({
  List<ActivityEventDto>? activities,
}) {
  final repo = MockActivityRepository();
  final list = activities ?? [];

  when(
    () => repo.getWorkspaceActivities(
      any(),
      limit: any(named: 'limit'),
      filter: any(named: 'filter'),
    ),
  ).thenAnswer((_) async => list);
  when(
    () => repo.getProjectActivities(any(), limit: any(named: 'limit')),
  ).thenAnswer((_) async => list);

  return repo;
}
