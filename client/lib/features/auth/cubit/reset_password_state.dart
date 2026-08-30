import 'package:freezed_annotation/freezed_annotation.dart';

part 'reset_password_state.freezed.dart';

@freezed
sealed class ResetPasswordState with _$ResetPasswordState {
  const factory ResetPasswordState.initial() = _ResetPasswordInitial;
  const factory ResetPasswordState.loading() = _ResetPasswordLoading;
  const factory ResetPasswordState.success() = _ResetPasswordSuccess;
  const factory ResetPasswordState.failure(String message) =
      _ResetPasswordFailure;
}
