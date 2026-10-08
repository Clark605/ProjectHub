import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:client/features/projects/data/models/project_status.dart';

part 'project_dto.freezed.dart';
part 'project_dto.g.dart';

class ProjectTaskCounts {
  final int total;
  final int backlog;
  final int todo;
  final int inProgress;
  final int review;
  final int done;

  const ProjectTaskCounts({
    this.total = 0,
    this.backlog = 0,
    this.todo = 0,
    this.inProgress = 0,
    this.review = 0,
    this.done = 0,
  });

  factory ProjectTaskCounts.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProjectTaskCounts();
    return ProjectTaskCounts(
      total: (json['total'] as num?)?.toInt() ?? 0,
      backlog: (json['backlog'] as num?)?.toInt() ?? 0,
      todo: (json['todo'] as num?)?.toInt() ?? 0,
      inProgress: (json['inProgress'] as num?)?.toInt() ?? 0,
      review: (json['review'] as num?)?.toInt() ?? 0,
      done: (json['done'] as num?)?.toInt() ?? 0,
    );
  }
}

class ProjectMemberSummary {
  final String id;
  final String name;

  const ProjectMemberSummary({required this.id, required this.name});

  factory ProjectMemberSummary.fromJson(Map<String, dynamic> json) {
    return ProjectMemberSummary(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class ProjectExtraData {
  final ProjectTaskCounts taskCounts;
  final List<ProjectMemberSummary> members;

  const ProjectExtraData({
    this.taskCounts = const ProjectTaskCounts(),
    this.members = const [],
  });
}

@freezed
abstract class ProjectDto with _$ProjectDto {
  const ProjectDto._();

  static final Expando<ProjectExtraData> _extras = Expando<ProjectExtraData>();

  const factory ProjectDto({
    required int id,
    required int workspaceId,
    required String name,
    @Default('') String description,
    @Default('Planning') String status,
    DateTime? dueDate,
    @Default('') String createdBy,
    @Default('') String createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProjectDto;

  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    final dto = _$ProjectDtoFromJson(json);
    _extras[dto] = ProjectExtraData(
      taskCounts: ProjectTaskCounts.fromJson(
        json['taskCounts'] as Map<String, dynamic>?,
      ),
      members:
          (json['members'] as List?)
              ?.map(
                (m) => ProjectMemberSummary.fromJson(m as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
    return dto;
  }

  ProjectStatus get statusEnum => ProjectStatus.fromString(status);

  ProjectTaskCounts get taskCounts =>
      _extras[this]?.taskCounts ?? const ProjectTaskCounts();

  List<ProjectMemberSummary> get members => _extras[this]?.members ?? const [];
}
