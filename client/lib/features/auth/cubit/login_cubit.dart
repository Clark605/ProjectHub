import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/login_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';

@injectable
class LoginCubit extends SafeActionCubit<LoginState> {
  final AuthRepository _authRepository;
  final AppAuthCubit _appAuthCubit;

  LoginCubit(this._authRepository, this._appAuthCubit)
    : super(const LoginState.initial());

  Future<void> login({required String email, required String password}) async {
    emit(const LoginState.loading());
    await safeExecute(
      () async {
        final user = await _authRepository.login(
          LoginDto(email: email, password: password),
        );
        _appAuthCubit.setAuthenticated(user);
        if (getIt.isRegistered<WorkspaceContextCubit>()) {
          await getIt<WorkspaceContextCubit>().reset();
        }
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
  }) async {
    emit(const LoginState.loading());
    await safeExecute(
      () async {
        final user = await _authRepository.externalLogin(
          provider: provider,
          idToken: idToken,
          accessToken: accessToken,
        );
        _appAuthCubit.setAuthenticated(user);
        if (getIt.isRegistered<WorkspaceContextCubit>()) {
          await getIt<WorkspaceContextCubit>().reset();
        }
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
