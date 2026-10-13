import 'package:client/core/errors/app_failure.dart';
import 'package:client/features/auth/data/models/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'login_state.freezed.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.initial() = _LoginInitial;
  const factory LoginState.loading() = _LoginLoading;
  const factory LoginState.success(User user) = _LoginSuccess;
  const factory LoginState.failure(AppFailure failure) = _LoginFailure;
}
