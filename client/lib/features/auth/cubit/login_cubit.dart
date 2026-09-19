import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/auth/cubit/login_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';

@injectable
class LoginCubit extends SafeActionCubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit(this._authRepository) : super(const LoginState.initial());

  Future<void> login({required String email, required String password}) async {
    emit(const LoginState.loading());
    await safeExecute(
      () async {
        final user = await _authRepository.login(
          LoginDto(email: email, password: password),
        );
        emit(LoginState.success(user));
        return user;
      },
      onError: (msg) => emit(LoginState.failure(msg)),
      logTag: 'LoginCubit',
    );
  }

  Future<void> loginWithGoogle() async {
    emit(const LoginState.loading());
    await safeExecute(
      () async {
        final user = await _authRepository.loginWithGoogle();
        emit(LoginState.success(user));
        return user;
      },
      onError: (msg) => emit(LoginState.failure(msg)),
      logTag: 'LoginCubit',
    );
  }

  Future<void> loginWithGithub() async {
    emit(const LoginState.loading());
    await safeExecute(
      () async {
        final user = await _authRepository.loginWithGithub();
        emit(LoginState.success(user));
        return user;
      },
      onError: (msg) => emit(LoginState.failure(msg)),
      logTag: 'LoginCubit',
    );
  }

  Future<void> externalLogin({
    required String provider,
    String? idToken,
    String? accessToken,
    String? code,
    String? redirectUri,
  }) async {
    emit(const LoginState.loading());
    await safeExecute(
      () async {
        final user = await _authRepository.externalLogin(
          provider: provider,
          idToken: idToken,
          accessToken: accessToken,
          code: code,
          redirectUri: redirectUri,
        );
        emit(LoginState.success(user));
        return user;
      },
      onError: (msg) => emit(LoginState.failure(msg)),
      logTag: 'LoginCubit',
    );
  }

  void reset() {
    emit(const LoginState.initial());
  }
}
