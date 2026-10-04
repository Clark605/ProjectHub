import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:client/features/tasks/data/models/parsed_task_draft_dto.dart';

part 'voice_task_state.freezed.dart';

@freezed
abstract class VoiceTaskState with _$VoiceTaskState {
  const factory VoiceTaskState.idle() = VoiceTaskIdle;
  const factory VoiceTaskState.requestingPermission() =
      VoiceTaskRequestingPermission;
  const factory VoiceTaskState.permissionDenied({
    @Default(false) bool permanentlyDenied,
  }) = VoiceTaskPermissionDenied;
  const factory VoiceTaskState.listening({
    @Default('') String recognizedText,
    @Default(0.0) double soundLevel,
  }) = VoiceTaskListening;
  const factory VoiceTaskState.parsing({required String fullText}) =
      VoiceTaskParsing;
  const factory VoiceTaskState.reviewDraft({
    required ParsedTaskDraftDto draft,
    required String rawSpokenText,
  }) = VoiceTaskReviewDraft;
  const factory VoiceTaskState.error({required String message}) =
      VoiceTaskError;
}

