import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/tasks/cubit/my_tasks_cubit.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';
import 'package:client/features/tasks/ui/my_tasks_screen.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class _MockTaskRepo implements TaskRepository {
  List<TaskDto> tasks = [];

  @override
  void clearCache([int? projectId]) {}

  @override
  Future<List<TaskDto>> getTasksByProject(int projectId, {String? status, String? assigneeId, String? priority, bool forceRefresh = false}) async => tasks;

  @override
  Future<List<TaskDto>> getMyTasks(int workspaceId, {bool forceRefresh = false}) async => tasks;

  @override
  Future<TaskDto> getTask(int taskId, {bool forceRefresh = false}) async => tasks.firstWhere((t) => t.id == taskId);

  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async => throw UnimplementedError();

  @override
  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request) async => throw UnimplementedError();

  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async => throw UnimplementedError();

  @override
  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId) async => throw UnimplementedError();

  @override
  Future<void> deleteTask(int taskId) async {}

  @override
  bool hasCachedTasks(int projectId) => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidgetUnderTest(MyTasksCubit cubit) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MyTasksScreen(cubit: cubit),
      ),
    );
  }

  testWidgets('MyTasksScreen renders header and empty state when no tasks exist', (tester) async {
    final repo = _MockTaskRepo();
    repo.tasks = [];
    final cubit = MyTasksCubit(repo);

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await cubit.loadMyTasks(10);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('Personal sprint backlog and assigned deliverables.'), findsOneWidget);
    expect(find.text('No Assigned Tasks'), findsOneWidget);
  });

  testWidgets('MyTasksScreen renders urgency sections when tasks are loaded', (tester) async {
    final repo = _MockTaskRepo();
    repo.tasks = [
      const TaskDto(
        id: 1,
        projectId: 1,
        projectName: 'Mobile App',
        title: 'Fix crash on launch',
        priority: 'Urgent',
        status: 'Todo',
      ),
      const TaskDto(
        id: 2,
        projectId: 1,
        projectName: 'Backend API',
        title: 'Implement token rotation',
        priority: 'High',
        status: 'InProgress',
      ),
    ];
    final cubit = MyTasksCubit(repo);

    await tester.pumpWidget(createWidgetUnderTest(cubit));
    await cubit.loadMyTasks(10);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Overdue & Urgent'), findsOneWidget);
    expect(find.text('Fix crash on launch'), findsOneWidget);
    expect(find.text('In Progress'), findsNWidgets(2));
    expect(find.text('Implement token rotation'), findsOneWidget);
  });
}
