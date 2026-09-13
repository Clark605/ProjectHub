import 'dart:convert';

class ActivityEventDto {
  final int id;
  final int workspaceId;
  final int? projectId;
  final int? taskId;
  final String actorId;
  final String actorName;
  final String eventType;
  final Map<String, dynamic>? metadata;
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
    Map<String, dynamic>? parsedMetadata;
    final rawMeta = json['metadata'];
    if (rawMeta is Map<String, dynamic>) {
      parsedMetadata = rawMeta;
    } else if (rawMeta is Map) {
      parsedMetadata = rawMeta.cast<String, dynamic>();
    } else if (rawMeta is String && rawMeta.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(rawMeta);
        if (decoded is Map<String, dynamic>) {
          parsedMetadata = decoded;
        } else if (decoded is Map) {
          parsedMetadata = decoded.cast<String, dynamic>();
        }
      } catch (_) {
        parsedMetadata = null;
      }
    }

    return ActivityEventDto(
      id: json['id'] as int? ?? 0,
      workspaceId: json['workspaceId'] as int? ?? 0,
      projectId: json['projectId'] as int?,
      taskId: json['taskId'] as int?,
      actorId: json['actorId'] as String? ?? '',
      actorName: json['actorName'] as String? ?? 'Team Member',
      eventType: json['eventType'] as String? ?? '',
      metadata: parsedMetadata,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Target item name or title (e.g. task title, project name, workspace name)
  String? get targetTitle =>
      metadata?['Title'] as String? ??
      metadata?['title'] as String? ??
      metadata?['Name'] as String? ??
      metadata?['name'] as String?;

  /// Status of the target entity
  String? get status =>
      metadata?['Status'] as String? ?? metadata?['status'] as String?;

  /// Updated destination status
  String? get newStatus =>
      metadata?['NewStatus'] as String? ?? metadata?['newStatus'] as String?;

  /// Previous origin status
  String? get oldStatus =>
      metadata?['OldStatus'] as String? ?? metadata?['oldStatus'] as String?;

  /// Assignee user name
  String? get assigneeName =>
      metadata?['AssigneeName'] as String? ??
      metadata?['assigneeName'] as String?;

  /// Added or removed member name
  String? get memberName =>
      metadata?['MemberName'] as String? ?? metadata?['memberName'] as String?;

  /// Workspace membership role
  String? get role =>
      metadata?['Role'] as String? ?? metadata?['role'] as String?;
}
