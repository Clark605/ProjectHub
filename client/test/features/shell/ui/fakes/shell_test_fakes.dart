import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/user.dart';
import 'package:client/features/dashboard/data/activity_repository.dart';
import 'package:client/features/dashboard/data/models/activity_event_dto.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';
import 'package:client/features/workspaces/data/workspace_repository.dart';

class FakeAuthRepository extends Fake implements AuthRepository {
  final _authStateController = StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<User?> restoreSession() async =>
      const User(name: 'Test Clark', email: 'clark@example.com');

  @override
  Future<User> getCurrentUser() async =>
      const User(name: 'Test Clark', email: 'clark@example.com');
}

class FakeWorkspaceRepository extends Fake implements WorkspaceRepository {
  List<WorkspaceDto> workspaces = [
    const WorkspaceDto(
      id: 1,
      name: 'Engineering Team',
      description: 'Core dev',
      membership: WorkspaceMembershipDto(role: 'Owner'),
    ),
  ];

  @override
  WorkspaceDto? get activeWorkspace => workspaces.firstOrNull;

  @override
  Stream<WorkspaceDto?> get activeWorkspaceChanges => const Stream.empty();

  @override
  void setActiveWorkspace(WorkspaceDto? workspace) {}

  @override
  Future<List<WorkspaceDto>> getWorkspaces({bool forceRefresh = false}) async => workspaces;

  @override
  Future<WorkspaceDto> getWorkspace(int id, {bool forceRefresh = false}) async =>
      workspaces.firstWhere((w) => w.id == id);

  @override
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request) async => WorkspaceDto(
        id: 2,
        name: request.name,
        description: request.description,
        membership: const WorkspaceMembershipDto(role: 'Owner'),
      );

  @override
  Future<WorkspaceDto> updateWorkspace(int id, UpdateWorkspaceRequest request) async =>
      WorkspaceDto(
        id: id,
        name: request.name,
        description: request.description,
        membership: const WorkspaceMembershipDto(role: 'Owner'),
      );

  @override
  Future<void> deleteWorkspace(int id) async {}

  @override
  Future<List<MemberDto>> getMembers(int workspaceId, {bool forceRefresh = false}) async => [];

  @override
  Future<MemberDto> addMember(int workspaceId, AddMemberRequest request) async => MemberDto(
        userId: 'u_new',
        name: 'New Member',
        email: request.email,
        role: 'Member',
        joinedAt: DateTime.now(),
      );

  @override
  Future<void> removeMember(int workspaceId, String userId) async {}

  @override
  bool hasCachedSettings(int workspaceId) => false;

  @override
  void clearCache([int? workspaceId]) {}
}

class FakeProjectRepository extends Fake implements ProjectRepository {
  List<ProjectDto> projects = [];

  @override
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  }) async => projects;

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async =>
      const ProjectDto(id: 1, name: 'Project 1', workspaceId: 1);

  @override
  Future<ProjectDto> createProject(int workspaceId, CreateProjectRequest request) async =>
      ProjectDto(id: 99, name: request.name, description: request.description, workspaceId: workspaceId);

  @override
  Future<ProjectDto> updateProject(int id, UpdateProjectRequest request) async =>
      ProjectDto(id: id, name: request.name, description: request.description, workspaceId: 1);

  @override
  Future<void> deleteProject(int id) async {}

  @override
  void clearCache([int? workspaceId]) {}

  @override
  bool hasCachedProjects(int workspaceId) => false;

  @override
  bool hasCachedProject(int id) => false;
}

class FakeActivityRepository extends Fake implements ActivityRepository {
  @override
  Future<List<ActivityEventDto>> getWorkspaceActivities(int workspaceId, {int limit = 20}) async => [];

  @override
  Future<List<ActivityEventDto>> getProjectActivities(int projectId, {int limit = 50}) async => [];
}

class FakeTaskRepository extends Fake implements TaskRepository {
  @override
  Future<List<TaskDto>> getMyTasks(int workspaceId, {bool forceRefresh = false}) async => [];

  @override
  Future<List<TaskDto>> getTasksByProject(
    int projectId, {
    String? status,
    String? assigneeId,
    String? priority,
    bool forceRefresh = false,
  }) async => [];

  @override
  Future<TaskDto> getTask(int taskId, {bool forceRefresh = false}) async =>
      const TaskDto(id: 1, title: 'Task 1', projectId: 1);

  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async =>
      TaskDto(id: 1, title: request.title, projectId: projectId);

  @override
  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request) async =>
      TaskDto(id: taskId, title: request.title, projectId: 1);

  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async =>
      TaskDto(id: taskId, title: 'Task', projectId: 1, status: status);

  @override
  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId) async =>
      TaskDto(id: taskId, title: 'Task', projectId: 1);

  @override
  Future<void> deleteTask(int taskId) async {}

  @override
  void clearCache([int? projectId]) {}

  @override
  bool hasCachedTasks(int projectId) => false;
}
