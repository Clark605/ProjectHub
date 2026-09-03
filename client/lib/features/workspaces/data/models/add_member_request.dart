import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_member_request.freezed.dart';
part 'add_member_request.g.dart';

@freezed
abstract class AddMemberRequest with _$AddMemberRequest {
  const factory AddMemberRequest({required String email}) = _AddMemberRequest;

  factory AddMemberRequest.fromJson(Map<String, dynamic> json) =>
      _$AddMemberRequestFromJson(json);
}
