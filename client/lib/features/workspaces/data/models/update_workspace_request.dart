import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_workspace_request.freezed.dart';
part 'update_workspace_request.g.dart';

@freezed
abstract class UpdateWorkspaceRequest with _$UpdateWorkspaceRequest {
  const factory UpdateWorkspaceRequest({
    required String name,
    @Default('') String description,
    required String accentColor,
  }) = _UpdateWorkspaceRequest;

  factory UpdateWorkspaceRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateWorkspaceRequestFromJson(json);
}
