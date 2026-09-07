// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskDto _$TaskDtoFromJson(Map<String, dynamic> json) => _TaskDto(
  id: (json['id'] as num).toInt(),
  projectId: (json['projectId'] as num).toInt(),
  projectName: json['projectName'] as String?,
  title: json['title'] as String,
  description: json['description'] as String? ?? '',
  status: json['status'] as String? ?? 'Backlog',
  priority: json['priority'] as String? ?? 'Medium',
  assigneeId: json['assigneeId'] as String?,
  assigneeName: json['assigneeName'] as String?,
  createdBy: json['createdBy'] as String? ?? '',
  createdByName: json['createdByName'] as String? ?? '',
  dueDate: json['dueDate'] == null
      ? null
      : DateTime.parse(json['dueDate'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TaskDtoToJson(_TaskDto instance) => <String, dynamic>{
  'id': instance.id,
  'projectId': instance.projectId,
  'projectName': instance.projectName,
  'title': instance.title,
  'description': instance.description,
  'status': instance.status,
  'priority': instance.priority,
  'assigneeId': instance.assigneeId,
  'assigneeName': instance.assigneeName,
  'createdBy': instance.createdBy,
  'createdByName': instance.createdByName,
  'dueDate': instance.dueDate?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
