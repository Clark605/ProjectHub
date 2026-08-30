import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/auth/cubit/forgot_password_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';

@injectable
class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final AuthRepository _authRepository;

  ForgotPasswordCubit(this._authRepository)
    : super(const ForgotPasswordState.initial());

  Future<void> sendResetCode({required String email}) async {
    emit(const ForgotPasswordState.loading());
    try {
      final response = await _authRepository.forgotPassword(
        ForgotPasswordDto(email: email),
      );
      emit(ForgotPasswordState.success(response));
    } on AppException catch (e) {
      emit(ForgotPasswordState.failure(e.message));
    } catch (_) {
      emit(const ForgotPasswordState.failure('An unexpected error occurred'));
    }
  }

  void reset() {
    emit(const ForgotPasswordState.initial());
  }
}
