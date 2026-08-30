import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';

part 'forgot_password_state.freezed.dart';

@freezed
sealed class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState.initial() = _ForgotPasswordInitial;
  const factory ForgotPasswordState.loading() = _ForgotPasswordLoading;
  const factory ForgotPasswordState.success(
    ForgotPasswordResponseDto response,
  ) = _ForgotPasswordSuccess;
  const factory ForgotPasswordState.failure(String message) =
      _ForgotPasswordFailure;
}
