import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:client/features/projects/data/models/project_status.dart';

part 'project_dto.freezed.dart';
part 'project_dto.g.dart';

@freezed
abstract class ProjectDto with _$ProjectDto {
  const ProjectDto._();

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

  ProjectStatus get statusEnum => ProjectStatus.fromString(status);
}
