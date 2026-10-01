import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/tasks/cubit/voice_task_state.dart';
import 'package:client/features/tasks/data/ai_task_repository.dart';
import 'package:client/features/tasks/data/models/create_task_request.dart';
import 'package:client/features/tasks/data/task_repository.dart';

@injectable
class VoiceTaskCubit extends Cubit<VoiceTaskState> {
  final AiTaskRepository _aiTaskRepository;
  final TaskRepository _taskRepository;
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  int? _projectId;
  int? _workspaceId;
  bool _speechInitialized = false;

  VoiceTaskCubit(this._aiTaskRepository, this._taskRepository)
    : super(const VoiceTaskState.idle());

  void setScope({required int projectId, required int workspaceId}) {
    _projectId = projectId;
    _workspaceId = workspaceId;
  }

  Future<void> toggleListening({
    required int projectId,
    required int workspaceId,
  }) async {
    setScope(projectId: projectId, workspaceId: workspaceId);
    if (state is VoiceTaskListening) {
      await stopListening();
    } else if (state is VoiceTaskIdle || state is VoiceTaskError) {
      await startListening();
    }
  }

  Future<void> startListening() async {
    emit(const VoiceTaskState.requestingPermission());

    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      emit(
        VoiceTaskState.permissionDenied(
          permanentlyDenied: status.isPermanentlyDenied,
        ),
      );
      return;
    }

    if (!_speechInitialized) {
      _speechInitialized = await _speechToText.initialize(
        onError: (err) {
          AppLogger.error('STT error: ${err.errorMsg}', tag: 'VoiceTaskCubit');
          if (state is VoiceTaskListening) {
            emit(VoiceTaskState.error(message: err.errorMsg));
          }
        },
        onStatus: (status) {
          AppLogger.debug('STT status: $status', tag: 'VoiceTaskCubit');
          if (status == 'done' && state is VoiceTaskListening) {
            final text = (state as VoiceTaskListening).recognizedText;
            if (text.trim().isNotEmpty) {
              _processTranscribedText(text);
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
            VoiceTaskState.listening(
              recognizedText: result.recognizedWords,
              soundLevel: 0.0,
            ),
          );
        }
      },
      listenOptions: stt.SpeechListenOptions(
        listenFor: const Duration(seconds: 45),
        pauseFor: const Duration(seconds: 4),
        cancelOnError: false,
        partialResults: true,
      ),
    );
  }

  Future<void> stopListening() async {
    final currentText = state is VoiceTaskListening
        ? (state as VoiceTaskListening).recognizedText
        : '';
    await _speechToText.stop();

    if (currentText.trim().isEmpty) {
      emit(const VoiceTaskState.idle());
      return;
    }

    await _processTranscribedText(currentText);
  }

  Future<void> cancelListening() async {
    await _speechToText.cancel();
    emit(const VoiceTaskState.idle());
  }

  Future<void> _processTranscribedText(String text) async {
    if (_projectId == null || _workspaceId == null) {
      emit(const VoiceTaskState.error(message: 'Missing project context.'));
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

  Future<void> confirmCreateTask({
    required CreateTaskRequest request,
    String? initialStatus,
  }) async {
    if (_projectId == null) return;
    emit(const VoiceTaskState.creating());

    try {
      var created = await _taskRepository.createTask(_projectId!, request);
      if (initialStatus != null &&
          initialStatus.toLowerCase() != 'backlog' &&
          initialStatus.isNotEmpty) {
        created = await _taskRepository.updateTaskStatus(
          created.id,
          initialStatus,
        );
      }
      emit(VoiceTaskState.success(createdTask: created));
    } catch (e) {
      AppLogger.error('Task creation failed', error: e, tag: 'VoiceTaskCubit');
      emit(VoiceTaskState.error(message: 'Failed to create task: $e'));
    }
  }

  void reset() => emit(const VoiceTaskState.idle());

  @override
  Future<void> close() async {
    await _speechToText.cancel();
    return super.close();
  }
}
