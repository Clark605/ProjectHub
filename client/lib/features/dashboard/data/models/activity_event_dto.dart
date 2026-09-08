class ActivityEventDto {
  final int id;
  final int workspaceId;
  final int? projectId;
  final int? taskId;
  final String actorId;
  final String actorName;
  final String eventType;
  final String? metadata;
  final DateTime createdAt;

  const ActivityEventDto({
    required this.id,
    required this.workspaceId,
    this.projectId,
    this.taskId,
    required this.actorId,
    required this.actorName,
    required this.eventType,
    this.metadata,
    required this.createdAt,
  });

  factory ActivityEventDto.fromJson(Map<String, dynamic> json) {
    return ActivityEventDto(
      id: json['id'] as int? ?? 0,
      workspaceId: json['workspaceId'] as int? ?? 0,
      projectId: json['projectId'] as int?,
      taskId: json['taskId'] as int?,
      actorId: json['actorId'] as String? ?? '',
      actorName: json['actorName'] as String? ?? 'Team Member',
      eventType: json['eventType'] as String? ?? '',
      metadata: json['metadata'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
