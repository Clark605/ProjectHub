import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_dtos.freezed.dart';
part 'auth_dtos.g.dart';

@freezed
abstract class LoginDto with _$LoginDto {
  const factory LoginDto({required String email, required String password}) =
      _LoginDto;

  factory LoginDto.fromJson(Map<String, dynamic> json) =>
      _$LoginDtoFromJson(json);
}

@freezed
abstract class RegisterDto with _$RegisterDto {
  const factory RegisterDto({
    required String name,
    required String email,
    required String password,
  }) = _RegisterDto;

  factory RegisterDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterDtoFromJson(json);
}

@freezed
abstract class AuthResponseDto with _$AuthResponseDto {
  const factory AuthResponseDto({
    required String token,
    required String refreshToken,
  }) = _AuthResponseDto;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseDtoFromJson(json);
}

@freezed
abstract class ForgotPasswordDto with _$ForgotPasswordDto {
  const factory ForgotPasswordDto({required String email}) = _ForgotPasswordDto;

  factory ForgotPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordDtoFromJson(json);
}

@freezed
abstract class ForgotPasswordResponseDto with _$ForgotPasswordResponseDto {
  const factory ForgotPasswordResponseDto({
    required String message,
    String? developmentResetToken,
  }) = _ForgotPasswordResponseDto;

  factory ForgotPasswordResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseDtoFromJson(json);
}

@freezed
abstract class ResetPasswordDto with _$ResetPasswordDto {
  const factory ResetPasswordDto({
    required String email,
    required String token,
    required String newPassword,
  }) = _ResetPasswordDto;

  factory ResetPasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordDtoFromJson(json);
}

@freezed
abstract class LogoutDto with _$LogoutDto {
  const factory LogoutDto({required String refreshToken}) = _LogoutDto;

  factory LogoutDto.fromJson(Map<String, dynamic> json) =>
      _$LogoutDtoFromJson(json);
}
