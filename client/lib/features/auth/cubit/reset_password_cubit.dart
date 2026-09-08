import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/auth/cubit/reset_password_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';

@injectable
class ResetPasswordCubit extends SafeActionCubit<ResetPasswordState> {
  final AuthRepository _authRepository;

  ResetPasswordCubit(this._authRepository)
    : super(const ResetPasswordState.initial());

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    emit(const ResetPasswordState.loading());
    await safeExecute(
      () async {
        await _authRepository.resetPassword(
          ResetPasswordDto(
            email: email,
            token: token,
            newPassword: newPassword,
          ),
        );
        emit(const ResetPasswordState.success());
        return true;
      },
      onError: (msg) => emit(ResetPasswordState.failure(msg)),
      logTag: 'ResetPasswordCubit',
    );
  }

  void reset() {
    emit(const ResetPasswordState.initial());
  }
}
