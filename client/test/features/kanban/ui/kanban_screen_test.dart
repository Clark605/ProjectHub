import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/routes/route_names.dart';
import 'package:client/features/kanban/cubit/kanban_cubit.dart';
import 'package:client/features/kanban/ui/kanban_screen.dart';
import 'package:client/features/projects/data/models/create_project_request.dart';
import 'package:client/features/projects/data/models/project_dto.dart';
import 'package:client/features/projects/data/models/update_project_request.dart';
import 'package:client/features/projects/data/project_repository.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const testProject = ProjectDto(
    id: 42,
    workspaceId: 1,
    name: 'Apollo Project',
    description: 'Mission to space',
    status: 'Active',
  );

  Widget createWidgetUnderTest({
    required int projectId,
    ProjectDto? initialProject,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routes: {
        RouteNames.projectDetail: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          return Scaffold(
            body: Center(child: Text('Settings for project $args')),
          );
        },
      },
      home: KanbanScreen(projectId: projectId, initialProject: initialProject),
    );
  }

  testWidgets('KanbanScreen renders project title and board content', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        projectId: testProject.id,
        initialProject: testProject,
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    // Verify title and subtitle
    expect(find.text('Apollo Project'), findsOneWidget);
    expect(find.text('Kanban Board'), findsOneWidget);
    expect(find.text('Board is Empty'), findsOneWidget);
    expect(find.text('New Task'), findsOneWidget);

    // Verify presence of settings icon button
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets(
    'KanbanScreen settings icon button opens project details screen',
    (tester) async {
      await tester.pumpWidget(
        createWidgetUnderTest(
          projectId: testProject.id,
          initialProject: testProject,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Tap settings icon in AppBar
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Verify navigation to settings
      expect(find.text('Settings for project 42'), findsOneWidget);
    },
  );

  testWidgets(
    'KanbanScreen renders responsive PageView on mobile viewport (390x844)',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeTaskRepo = _TestTaskRepository([
        const TaskDto(
          id: 101,
          projectId: 42,
          title: 'Mobile Architecture Task',
          status: 'Backlog',
          priority: 'High',
        ),
      ]);
      final fakeProjectRepo = _TestProjectRepository(testProject);
      final cubit = KanbanCubit(fakeTaskRepo, fakeProjectRepo);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: KanbanScreen(
            projectId: testProject.id,
            initialProject: testProject,
            cubit: cubit,
          ),
        ),
      );
      await cubit.loadTasks(testProject.id);
      await tester.pump(const Duration(milliseconds: 300));

      // Mobile PageView and tab chip should be present
      expect(find.byType(PageView), findsOneWidget);
      expect(find.text('Backlog (1)'), findsOneWidget);
      expect(find.text('Mobile Architecture Task'), findsOneWidget);
    },
  );

  testWidgets(
    'KanbanScreen renders horizontal multi-column board on desktop viewport (1200x800)',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeTaskRepo = _TestTaskRepository([
        const TaskDto(
          id: 101,
          projectId: 42,
          title: 'Desktop Multi-column Task',
          status: 'Backlog',
          priority: 'Medium',
        ),
      ]);
      final fakeProjectRepo = _TestProjectRepository(testProject);
      final cubit = KanbanCubit(fakeTaskRepo, fakeProjectRepo);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: KanbanScreen(
            projectId: testProject.id,
            initialProject: testProject,
            cubit: cubit,
          ),
        ),
      );
      await cubit.loadTasks(testProject.id);
      await tester.pump(const Duration(milliseconds: 300));

      // Desktop board has SingleChildScrollView with horizontal scroll and no PageView
      expect(find.byType(PageView), findsNothing);
      expect(find.text('Desktop Multi-column Task'), findsOneWidget);
      expect(find.text('Backlog'), findsAtLeast(1));
      expect(find.text('To Do'), findsAtLeast(1));
    },
  );
}

class _TestTaskRepository implements TaskRepository {
  final List<TaskDto> _tasks;
  _TestTaskRepository(this._tasks);

  @override
  void clearCache([int? projectId]) {}

  @override
  Future<List<TaskDto>> getTasksByProject(
    int projectId, {
    String? status,
    String? assigneeId,
    String? priority,
    bool forceRefresh = false,
  }) async => _tasks;

  @override
  Future<List<TaskDto>> getMyTasks(
    int workspaceId, {
    bool forceRefresh = false,
  }) async => _tasks;

  @override
  Future<TaskDto> getTask(int taskId, {bool forceRefresh = false}) async =>
      _tasks.firstWhere((t) => t.id == taskId);

  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async =>
      throw UnimplementedError();

  @override
  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request) async =>
      throw UnimplementedError();

  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async =>
      throw UnimplementedError();

  @override
  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId) async =>
      throw UnimplementedError();

  @override
  Future<void> deleteTask(int taskId) async {}

  @override
  bool hasCachedTasks(int projectId) => false;
}

class _TestProjectRepository implements ProjectRepository {
  final ProjectDto _project;
  _TestProjectRepository(this._project);

  @override
  void clearCache([int? workspaceId]) {}

  @override
  Future<List<ProjectDto>> getProjects(
    int workspaceId, {
    String? status,
    bool forceRefresh = false,
  }) async => [_project];

  @override
  Future<ProjectDto> getProject(int id, {bool forceRefresh = false}) async =>
      _project;

  @override
  Future<ProjectDto> createProject(
    int workspaceId,
    CreateProjectRequest request,
  ) async => _project;

  @override
  Future<ProjectDto> updateProject(
    int id,
    UpdateProjectRequest request,
  ) async => _project;

  @override
  Future<void> deleteProject(int id) async {}

  @override
  bool hasCachedProjects(int workspaceId) => false;

  @override
  bool hasCachedProject(int id) => false;
}
