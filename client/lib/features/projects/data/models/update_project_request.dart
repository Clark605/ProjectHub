import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_project_request.freezed.dart';
part 'update_project_request.g.dart';

@freezed
abstract class UpdateProjectRequest with _$UpdateProjectRequest {
  const factory UpdateProjectRequest({
    required String name,
    @Default('') String description,
    @Default('Planning') String status,
    DateTime? dueDate,
  }) = _UpdateProjectRequest;

  factory UpdateProjectRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProjectRequestFromJson(json);
}
