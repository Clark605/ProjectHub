import 'package:freezed_annotation/freezed_annotation.dart';

part 'parsed_task_draft_dto.freezed.dart';
part 'parsed_task_draft_dto.g.dart';

@freezed
abstract class ParsedTaskDraftDto with _$ParsedTaskDraftDto {
  const factory ParsedTaskDraftDto({
    required String title,
    @Default('') String description,
    @Default('Medium') String priority,
    String? assigneeId,
    String? assigneeName,
    DateTime? dueDate,
    @Default([]) List<String> warnings,
  }) = _ParsedTaskDraftDto;

  factory ParsedTaskDraftDto.fromJson(Map<String, dynamic> json) =>
      _$ParsedTaskDraftDtoFromJson(json);
}
