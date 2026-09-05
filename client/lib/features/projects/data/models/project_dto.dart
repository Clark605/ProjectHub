import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_dto.freezed.dart';
part 'project_dto.g.dart';

@freezed
abstract class ProjectDto with _$ProjectDto {
  const factory ProjectDto({
    required int id,
    required int workspaceId,
    required String name,
    @Default('') String description,
    @Default('Planning') String status,
    DateTime? dueDate,
    @Default('') String createdBy,
    @Default('') String createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProjectDto;

  factory ProjectDto.fromJson(Map<String, dynamic> json) =>
      _$ProjectDtoFromJson(json);
}
