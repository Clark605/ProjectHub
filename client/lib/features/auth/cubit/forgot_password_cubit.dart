import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/auth/cubit/forgot_password_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';

@injectable
class ForgotPasswordCubit extends SafeActionCubit<ForgotPasswordState> {
  final AuthRepository _authRepository;

  ForgotPasswordCubit(this._authRepository)
    : super(const ForgotPasswordState.initial());

  Future<void> sendResetCode({required String email}) async {
    emit(const ForgotPasswordState.loading());
    await safeExecute(
      () async {
        final response = await _authRepository.forgotPassword(
          ForgotPasswordDto(email: email),
        );
        emit(ForgotPasswordState.success(response));
        return response;
      },
      onError: (msg) => emit(ForgotPasswordState.failure(msg)),
      logTag: 'ForgotPasswordCubit',
    );
  }

  void reset() {
    emit(const ForgotPasswordState.initial());
  }
}
