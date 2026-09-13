// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_workspace_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateWorkspaceRequest _$UpdateWorkspaceRequestFromJson(
  Map<String, dynamic> json,
) => _UpdateWorkspaceRequest(
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
  accentColor: json['accentColor'] as String,
);

Map<String, dynamic> _$UpdateWorkspaceRequestToJson(
  _UpdateWorkspaceRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
  'accentColor': instance.accentColor,
};
