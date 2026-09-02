import 'package:freezed_annotation/freezed_annotation.dart';

part 'workspace_dto.freezed.dart';
part 'workspace_dto.g.dart';

@freezed
abstract class WorkspaceMembershipDto with _$WorkspaceMembershipDto {
  const factory WorkspaceMembershipDto({
    required String role,
    DateTime? joinedAt,
  }) = _WorkspaceMembershipDto;

  factory WorkspaceMembershipDto.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceMembershipDtoFromJson(json);
}

@freezed
abstract class WorkspaceDto with _$WorkspaceDto {
  const factory WorkspaceDto({
    required int id,
    required String name,
    @Default('') String description,
    WorkspaceMembershipDto? membership,
  }) = _WorkspaceDto;

  factory WorkspaceDto.fromJson(Map<String, dynamic> json) =>
      _$WorkspaceDtoFromJson(json);
}
