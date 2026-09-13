// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkspaceMembershipDto _$WorkspaceMembershipDtoFromJson(
  Map<String, dynamic> json,
) => _WorkspaceMembershipDto(
  role: json['role'] as String,
  joinedAt: json['joinedAt'] == null
      ? null
      : DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$WorkspaceMembershipDtoToJson(
  _WorkspaceMembershipDto instance,
) => <String, dynamic>{
  'role': instance.role,
  'joinedAt': instance.joinedAt?.toIso8601String(),
};

_WorkspaceDto _$WorkspaceDtoFromJson(Map<String, dynamic> json) =>
    _WorkspaceDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      accentColor: json['accentColor'] as String? ?? 'teal',
      membership: json['membership'] == null
          ? null
          : WorkspaceMembershipDto.fromJson(
              json['membership'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$WorkspaceDtoToJson(_WorkspaceDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'accentColor': instance.accentColor,
      'membership': instance.membership,
    };
