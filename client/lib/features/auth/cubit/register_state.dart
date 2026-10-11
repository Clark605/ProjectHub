import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:client/core/errors/app_failure.dart';
import 'package:client/features/auth/data/models/user.dart';

part 'register_state.freezed.dart';

@freezed
sealed class RegisterState with _$RegisterState {
  const factory RegisterState.initial() = _RegisterInitial;
  const factory RegisterState.loading() = _RegisterLoading;
  const factory RegisterState.success(User user) = _RegisterSuccess;
  const factory RegisterState.failure(AppFailure failure) = _RegisterFailure;
}
