import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/storage/secure_storage_service.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/user.dart';

@lazySingleton
class AppAuthCubit extends Cubit<AppAuthState> {
  final AuthRepository _authRepository;
  final SecureStorageService _storage;

  AppAuthCubit(this._authRepository, this._storage)
    : super(const AppAuthState.initial());

  Future<void> checkAuthStatus() async {
    final hasToken = await _storage.hasTokens();
    if (!hasToken) {
      emit(const AppAuthState.unauthenticated());
      return;
    }

    try {
      final user = await _authRepository.getCurrentUser();
      emit(AppAuthState.authenticated(user));
    } catch (_) {
      // If token refresh failed or token is invalid, interceptor clears storage
      emit(const AppAuthState.unauthenticated());
    }
  }

  void setAuthenticated(User user) {
    emit(AppAuthState.authenticated(user));
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(const AppAuthState.unauthenticated());
  }
}
