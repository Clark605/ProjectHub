import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/tasks/cubit/voice_task_state.dart';

import '../../../helpers/mock_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VoiceTaskCubit', () {
    late MockAiTaskRepository mockAiRepo;

    setUp(() {
      mockAiRepo = MockAiTaskRepository();
    });

    test('initial state is idle', () {
      final cubit = VoiceTaskCubit(mockAiRepo);
      expect(cubit.state, const VoiceTaskState.idle());
      cubit.close();
    });

    blocTest<VoiceTaskCubit, VoiceTaskState>(
      'reset() emits idle',
      build: () => VoiceTaskCubit(mockAiRepo),
      seed: () => const VoiceTaskState.listening(),
      act: (cubit) => cubit.reset(),
      expect: () => [const VoiceTaskState.idle()],
    );

    blocTest<VoiceTaskCubit, VoiceTaskState>(
      'cancelListening() emits idle',
      build: () => VoiceTaskCubit(mockAiRepo),
      seed: () => const VoiceTaskState.listening(),
      act: (cubit) => cubit.cancelListening(),
      expect: () => [const VoiceTaskState.idle()],
    );
  });
}
