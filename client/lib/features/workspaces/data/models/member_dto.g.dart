// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemberDto _$MemberDtoFromJson(Map<String, dynamic> json) => _MemberDto(
  userId: json['userId'] as String,
  name: json['name'] as String,
  email: json['email'] as String,
  role: json['role'] as String,
  joinedAt: DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$MemberDtoToJson(_MemberDto instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
