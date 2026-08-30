import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:client/features/auth/data/models/user.dart';

part 'login_state.freezed.dart';

@freezed
sealed class LoginState with _$LoginState {
  const factory LoginState.initial() = _LoginInitial;
  const factory LoginState.loading() = _LoginLoading;
  const factory LoginState.success(User user) = _LoginSuccess;
  const factory LoginState.failure(String message) = _LoginFailure;
}
