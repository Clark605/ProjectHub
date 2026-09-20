import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/user.dart';

@lazySingleton
class AppAuthCubit extends SafeActionCubit<AppAuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  AppAuthCubit(this._authRepository) : super(const AppAuthState.initial()) {
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        emit(AppAuthState.authenticated(user));
      } else {
        emit(const AppAuthState.unauthenticated());
      }
    });
  }

  Future<void> checkAuthStatus() async {
    final user = await _authRepository.restoreSession();
    if (user != null) {
      emit(AppAuthState.authenticated(user));
    } else {
      state.maybeWhen(
        authenticated: (_) {},
        orElse: () => emit(const AppAuthState.unauthenticated()),
      );
    }
  }

  Future<void> syncUser() async {
    await safeExecute(() async {
      final user = await _authRepository.getCurrentUser();
      emit(AppAuthState.authenticated(user));
      return user;
    }, logTag: 'Auth');
  }

  void setAuthenticated(User user) {
    _authRepository.setAuthenticated(user);
  }

  Future<void> logout() async {
    await safeExecute(() async {
      await _authRepository.logout();
      return true;
    }, logTag: 'Auth');
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
