// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parsed_task_draft_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ParsedTaskDraftDto _$ParsedTaskDraftDtoFromJson(Map<String, dynamic> json) =>
    _ParsedTaskDraftDto(
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Medium',
      assigneeId: json['assigneeId'] as String?,
      assigneeName: json['assigneeName'] as String?,
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      warnings:
          (json['warnings'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ParsedTaskDraftDtoToJson(_ParsedTaskDraftDto instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'priority': instance.priority,
      'assigneeId': instance.assigneeId,
      'assigneeName': instance.assigneeName,
      'dueDate': instance.dueDate?.toIso8601String(),
      'warnings': instance.warnings,
    };
