import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/auth/cubit/reset_password_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';

@injectable
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository _authRepository;

  ResetPasswordCubit(this._authRepository)
    : super(const ResetPasswordState.initial());

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    emit(const ResetPasswordState.loading());
    try {
      await _authRepository.resetPassword(
        ResetPasswordDto(email: email, token: token, newPassword: newPassword),
      );
      emit(const ResetPasswordState.success());
    } on AppException catch (e) {
      emit(ResetPasswordState.failure(e.message));
    } catch (_) {
      emit(const ResetPasswordState.failure('An unexpected error occurred'));
    }
  }

  void reset() {
    emit(const ResetPasswordState.initial());
  }
}
