import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/auth/cubit/register_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';

@injectable
class RegisterCubit extends SafeActionCubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterCubit(this._authRepository) : super(const RegisterState.initial());

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const RegisterState.loading());
    await safeExecute(
      () async {
        final user = await _authRepository.register(
          RegisterDto(name: name, email: email, password: password),
        );
        emit(RegisterState.success(user));
        return user;
      },
      onError: (msg) => emit(RegisterState.failure(msg)),
      logTag: 'RegisterCubit',
    );
  }

  Future<void> registerWithGoogle() async {
    emit(const RegisterState.loading());
    await safeExecute(
      () async {
        final user = await _authRepository.loginWithGoogle();
        emit(RegisterState.success(user));
        return user;
      },
      onError: (msg) => emit(RegisterState.failure(msg)),
      logTag: 'RegisterCubit',
    );
  }

  Future<void> registerWithGithub() async {
    emit(const RegisterState.loading());
    await safeExecute(
      () async {
        final user = await _authRepository.loginWithGithub();
        emit(RegisterState.success(user));
        return user;
      },
      onError: (msg) => emit(RegisterState.failure(msg)),
      logTag: 'RegisterCubit',
    );
  }

  Future<void> externalLogin({
    required String provider,
    String? idToken,
    String? accessToken,
    String? code,
    String? redirectUri,
  }) async {
    emit(const RegisterState.loading());
    await safeExecute(
      () async {
        final user = await _authRepository.externalLogin(
          provider: provider,
          idToken: idToken,
          accessToken: accessToken,
          code: code,
          redirectUri: redirectUri,
        );
        emit(RegisterState.success(user));
        return user;
      },
      onError: (msg) => emit(RegisterState.failure(msg)),
      logTag: 'RegisterCubit',
    );
  }

  void reset() {
    emit(const RegisterState.initial());
  }
}
