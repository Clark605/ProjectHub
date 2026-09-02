// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_workspace_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateWorkspaceRequest _$CreateWorkspaceRequestFromJson(
  Map<String, dynamic> json,
) => _CreateWorkspaceRequest(
  name: json['name'] as String,
  description: json['description'] as String? ?? '',
);

Map<String, dynamic> _$CreateWorkspaceRequestToJson(
  _CreateWorkspaceRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'description': instance.description,
};
