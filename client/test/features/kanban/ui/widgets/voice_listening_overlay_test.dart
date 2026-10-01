import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/theme/dark_theme.dart';
import 'package:client/features/kanban/ui/widgets/voice_listening_overlay.dart';
import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/tasks/data/ai_task_repository.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/parsed_task_draft_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';

class _FakeAiRepo implements AiTaskRepository {
  @override
  Future<ParsedTaskDraftDto> parseTaskFromText({
    required String text,
    required int projectId,
    required int workspaceId,
  }) async =>
      const ParsedTaskDraftDto(title: 'Title');
}

class _FakeTaskRepo implements TaskRepository {
  @override
  void clearCache([int? projectId]) {}
  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async =>
      throw UnimplementedError();
  @override
  Future<void> deleteTask(int taskId) async {}
  @override
  Future<List<TaskDto>> getMyTasks(int workspaceId, {bool forceRefresh = false}) async => [];
  @override
  Future<TaskDto> getTask(int taskId, {bool forceRefresh = false}) async => throw UnimplementedError();
  @override
  Future<List<TaskDto>> getTasksByProject(int projectId, {String? status, String? assigneeId, String? priority, bool forceRefresh = false}) async => [];
  @override
  bool hasCachedTasks(int projectId) => false;
  @override
  Future<TaskDto> updateTask(int taskId, UpdateTaskRequest request) async => throw UnimplementedError();
  @override
  Future<TaskDto> updateTaskAssignee(int taskId, String? assigneeId) async => throw UnimplementedError();
  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async => throw UnimplementedError();
}

void main() {
  testWidgets('VoiceListeningOverlay renders cleanly under DarkTheme with no infinite width error', (tester) async {
    final cubit = VoiceTaskCubit(_FakeAiRepo(), _FakeTaskRepo());

    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: VoiceListeningOverlay(
              onCancel: () {},
              onDone: () {},
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Listening...'), findsOneWidget);
    expect(find.text('Done Speaking'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await cubit.close();
  });
}
