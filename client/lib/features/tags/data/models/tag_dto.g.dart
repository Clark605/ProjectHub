// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TagDto _$TagDtoFromJson(Map<String, dynamic> json) => _TagDto(
  id: (json['id'] as num).toInt(),
  workspaceId: (json['workspaceId'] as num).toInt(),
  projectId: (json['projectId'] as num?)?.toInt(),
  name: json['name'] as String,
  color: json['color'] as String,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$TagDtoToJson(_TagDto instance) => <String, dynamic>{
  'id': instance.id,
  'workspaceId': instance.workspaceId,
  'projectId': instance.projectId,
  'name': instance.name,
  'color': instance.color,
  'createdAt': instance.createdAt?.toIso8601String(),
};
