// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_dtos.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginDto _$LoginDtoFromJson(Map<String, dynamic> json) => _LoginDto(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginDtoToJson(_LoginDto instance) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
};

_RegisterDto _$RegisterDtoFromJson(Map<String, dynamic> json) => _RegisterDto(
  name: json['name'] as String,
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$RegisterDtoToJson(_RegisterDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
    };

_AuthResponseDto _$AuthResponseDtoFromJson(Map<String, dynamic> json) =>
    _AuthResponseDto(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$AuthResponseDtoToJson(_AuthResponseDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refreshToken': instance.refreshToken,
    };

_ForgotPasswordDto _$ForgotPasswordDtoFromJson(Map<String, dynamic> json) =>
    _ForgotPasswordDto(email: json['email'] as String);

Map<String, dynamic> _$ForgotPasswordDtoToJson(_ForgotPasswordDto instance) =>
    <String, dynamic>{'email': instance.email};

_ForgotPasswordResponseDto _$ForgotPasswordResponseDtoFromJson(
  Map<String, dynamic> json,
) => _ForgotPasswordResponseDto(
  message: json['message'] as String,
  developmentResetToken: json['developmentResetToken'] as String?,
);

Map<String, dynamic> _$ForgotPasswordResponseDtoToJson(
  _ForgotPasswordResponseDto instance,
) => <String, dynamic>{
  'message': instance.message,
  'developmentResetToken': instance.developmentResetToken,
};

_ResetPasswordDto _$ResetPasswordDtoFromJson(Map<String, dynamic> json) =>
    _ResetPasswordDto(
      email: json['email'] as String,
      token: json['token'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$ResetPasswordDtoToJson(_ResetPasswordDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'token': instance.token,
      'newPassword': instance.newPassword,
    };

_LogoutDto _$LogoutDtoFromJson(Map<String, dynamic> json) =>
    _LogoutDto(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$LogoutDtoToJson(_LogoutDto instance) =>
    <String, dynamic>{'refreshToken': instance.refreshToken};
