import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/tasks/cubit/voice_task_state.dart';
import 'package:client/features/tasks/data/ai_task_repository.dart';
import 'package:client/features/tasks/data/models/parsed_task_draft_dto.dart';

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VoiceTaskCubit', () {
    late _FakeAiTaskRepo fakeAiRepo;
    late VoiceTaskCubit cubit;

    setUp(() {
      fakeAiRepo = _FakeAiTaskRepo();
      cubit = VoiceTaskCubit(fakeAiRepo);
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

    test('cancelListening() emits idle', () async {
      await cubit.cancelListening();
      expect(cubit.state, const VoiceTaskState.idle());
    });
  });
}
