import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/tasks/cubit/voice_task_state.dart';
import 'package:client/features/tasks/data/ai_task_repository.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/models/parsed_task_draft_dto.dart';
import 'package:client/features/tasks/data/models/task_dto.dart';
import 'package:client/features/tasks/data/models/update_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';

class _FakeAiTaskRepo implements AiTaskRepository {
  ParsedTaskDraftDto? response;
  Object? errorToThrow;

  @override
  Future<ParsedTaskDraftDto> parseTaskFromText({
    required String text,
    required int projectId,
    required int workspaceId,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return response ??
        const ParsedTaskDraftDto(
          title: 'Parsed Title',
          description: 'Parsed Description',
        );
  }
}

class _FakeTaskRepo implements TaskRepository {
  CreateTaskRequest? lastCreatedRequest;

  @override
  Future<TaskDto> createTask(int projectId, CreateTaskRequest request) async {
    lastCreatedRequest = request;
    return TaskDto(
      id: 99,
      projectId: projectId,
      title: request.title,
      description: request.description,
      priority: request.priority,
    );
  }

  @override
  Future<TaskDto> updateTaskStatus(int taskId, String status) async {
    return TaskDto(
      id: taskId,
      projectId: 1,
      title: 'Task',
      status: status,
    );
  }

  @override
  void clearCache([int? projectId]) {}
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
}

void main() {
  group('VoiceTaskCubit', () {
    late _FakeAiTaskRepo fakeAiRepo;
    late _FakeTaskRepo fakeTaskRepo;
    late VoiceTaskCubit cubit;

    setUp(() {
      fakeAiRepo = _FakeAiTaskRepo();
      fakeTaskRepo = _FakeTaskRepo();
      cubit = VoiceTaskCubit(fakeAiRepo, fakeTaskRepo);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('initial state is idle', () {
      expect(cubit.state, const VoiceTaskState.idle());
    });

    test('reset() emits idle', () {
      cubit.reset();
      expect(cubit.state, const VoiceTaskState.idle());
    });

    test('confirmCreateTask creates task and emits success', () async {
      cubit.setScope(projectId: 42, workspaceId: 10);

      const request = CreateTaskRequest(
        title: 'Voice Task Title',
        description: '- Point 1\n- Point 2',
        priority: 'Urgent',
      );

      await cubit.confirmCreateTask(request: request, initialStatus: 'InProgress');

      expect(fakeTaskRepo.lastCreatedRequest?.title, 'Voice Task Title');
      expect(fakeTaskRepo.lastCreatedRequest?.priority, 'Urgent');
      expect(cubit.state, isA<VoiceTaskSuccess>());
      final success = cubit.state as VoiceTaskSuccess;
      expect(success.createdTask.title, 'Task');
      expect(success.createdTask.status, 'InProgress');
    });
  });
}
