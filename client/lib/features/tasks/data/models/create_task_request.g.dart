// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) =>
    _CreateTaskRequest(
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Medium',
      assigneeId: json['assigneeId'] as String?,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      tagIds:
          (json['tagIds'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CreateTaskRequestToJson(_CreateTaskRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'priority': instance.priority,
      'assigneeId': instance.assigneeId,
      'dueDate': instance.dueDate?.toIso8601String(),
      'tagIds': instance.tagIds,
    };
