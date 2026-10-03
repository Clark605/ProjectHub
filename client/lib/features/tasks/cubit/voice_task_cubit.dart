import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/tasks/cubit/voice_task_state.dart';
import 'package:client/features/tasks/data/ai_task_repository.dart';

@injectable
class VoiceTaskCubit extends Cubit<VoiceTaskState> {
  final AiTaskRepository _aiTaskRepository;
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  int? _projectId;
  int? _workspaceId;
  bool _speechInitialized = false;

  VoiceTaskCubit(this._aiTaskRepository) : super(const VoiceTaskState.idle());

  void setScope({required int projectId, required int workspaceId}) {
    _projectId = projectId;
    _workspaceId = workspaceId;
  }

  Future<void> toggleListening({
    required int projectId,
    required int workspaceId,
  }) async {
    _projectId = projectId;
    _workspaceId = workspaceId;

    if (state is VoiceTaskListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    emit(const VoiceTaskState.requestingPermission());

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      AppLogger.warning('Microphone permission denied', tag: 'VoiceTaskCubit');
      emit(
        VoiceTaskState.permissionDenied(
          permanentlyDenied: status.isPermanentlyDenied,
        ),
      );
      return;
    }

    if (!_speechInitialized) {
      _speechInitialized = await _speechToText.initialize(
        onError: (val) {
          AppLogger.error('STT error: ${val.errorMsg}', tag: 'VoiceTaskCubit');
          if (state is VoiceTaskListening) {
            emit(VoiceTaskState.error(message: val.errorMsg));
          }
        },
        onStatus: (val) {
          AppLogger.debug('STT status: $val', tag: 'VoiceTaskCubit');
          if (val == 'done' && state is VoiceTaskListening) {
            final currentText = (state as VoiceTaskListening).recognizedText;
            if (currentText.trim().isNotEmpty) {
              _processTranscribedText(currentText);
            } else {
              emit(const VoiceTaskState.idle());
            }
          }
        },
      );
    }

    if (!_speechInitialized) {
      emit(
        const VoiceTaskState.error(
          message: 'Speech recognition is not available on this device.',
        ),
      );
      return;
    }

    emit(const VoiceTaskState.listening());

    await _speechToText.listen(
      onResult: (result) {
        if (state is VoiceTaskListening) {
          emit(
            VoiceTaskState.listening(recognizedText: result.recognizedWords),
          );
        }
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> stopListening() async {
    final currentText = state is VoiceTaskListening
        ? (state as VoiceTaskListening).recognizedText
        : '';

    await _speechToText.stop();

    if (currentText.trim().isNotEmpty) {
      await _processTranscribedText(currentText);
    } else {
      emit(const VoiceTaskState.idle());
    }
  }

  Future<void> cancelListening() async {
    await _speechToText.cancel();
    emit(const VoiceTaskState.idle());
  }

  Future<void> _processTranscribedText(String text) async {
    if (_projectId == null || _workspaceId == null) {
      emit(const VoiceTaskState.error(message: 'Project context is missing.'));
      return;
    }

    emit(VoiceTaskState.parsing(fullText: text));

    try {
      final draft = await _aiTaskRepository.parseTaskFromText(
        text: text,
        projectId: _projectId!,
        workspaceId: _workspaceId!,
      );

      emit(VoiceTaskState.reviewDraft(draft: draft, rawSpokenText: text));
    } catch (e) {
      AppLogger.error('AI parse failed', error: e, tag: 'VoiceTaskCubit');
      emit(
        const VoiceTaskState.error(
          message: 'Failed to understand task. Please try again.',
        ),
      );
    }
  }

  void reset() => emit(const VoiceTaskState.idle());

  @override
  Future<void> close() async {
    await _speechToText.cancel();
    return super.close();
  }
}
