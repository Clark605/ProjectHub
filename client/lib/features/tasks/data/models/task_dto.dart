import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:client/features/tasks/data/models/task_priority.dart';
import 'package:client/features/tasks/data/models/task_status.dart';

part 'task_dto.freezed.dart';
part 'task_dto.g.dart';

@freezed
abstract class TaskDto with _$TaskDto {
  const TaskDto._();

  const factory TaskDto({
    required int id,
    required int projectId,
    String? projectName,
    required String title,
    @Default('') String description,
    @Default('Backlog') String status,
    @Default('Medium') String priority,
    String? assigneeId,
    String? assigneeName,
    @Default('') String createdBy,
    @Default('') String createdByName,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TaskDto;

  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);

  TaskStatus get statusEnum => TaskStatus.fromString(status);
  TaskPriority get priorityEnum => TaskPriority.fromString(priority);
  bool get isOverdue {
    if (dueDate == null || statusEnum == TaskStatus.done) return false;
    final now = DateTime.now();
    if (dueDate!.hour == 0 && dueDate!.minute == 0 && dueDate!.second == 0) {
      final endOfDay = DateTime(
        dueDate!.year,
        dueDate!.month,
        dueDate!.day,
        23,
        59,
        59,
        999,
      );
      return endOfDay.isBefore(now);
    }
    return dueDate!.isBefore(now);
  }
}
