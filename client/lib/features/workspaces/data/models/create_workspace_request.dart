import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_workspace_request.freezed.dart';
part 'create_workspace_request.g.dart';

@freezed
abstract class CreateWorkspaceRequest with _$CreateWorkspaceRequest {
  const factory CreateWorkspaceRequest({
    required String name,
    @Default('') String description,
  }) = _CreateWorkspaceRequest;

  factory CreateWorkspaceRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateWorkspaceRequestFromJson(json);
}
