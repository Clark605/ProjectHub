import 'package:freezed_annotation/freezed_annotation.dart';

part 'member_dto.freezed.dart';
part 'member_dto.g.dart';

@freezed
abstract class MemberDto with _$MemberDto {
  const factory MemberDto({
    required String userId,
    required String name,
    required String email,
    required String role,
    required DateTime joinedAt,
  }) = _MemberDto;

  factory MemberDto.fromJson(Map<String, dynamic> json) =>
      _$MemberDtoFromJson(json);
}
