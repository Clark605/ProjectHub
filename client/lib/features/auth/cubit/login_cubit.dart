import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/errors/app_exception.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/login_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';

@injectable
class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;
  final AppAuthCubit _appAuthCubit;

  LoginCubit(this._authRepository, this._appAuthCubit)
    : super(const LoginState.initial());

  Future<void> login({required String email, required String password}) async {
    emit(const LoginState.loading());
    try {
      final user = await _authRepository.login(
        LoginDto(email: email, password: password),
      );
      _appAuthCubit.setAuthenticated(user);
      emit(LoginState.success(user));
    } on AppException catch (e) {
      emit(LoginState.failure(e.message));
    } catch (_) {
      emit(const LoginState.failure('An unexpected error occurred'));
    }
  }

  void reset() {
    emit(const LoginState.initial());
  }
}
