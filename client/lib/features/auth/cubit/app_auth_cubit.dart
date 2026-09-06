import 'dart:convert';

import 'package:injectable/injectable.dart';

import 'package:client/core/cubit/safe_action_cubit.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/core/storage/secure_storage_service.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/core/utils/jwt_utils.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/user.dart';

@lazySingleton
class AppAuthCubit extends SafeActionCubit<AppAuthState> {
  final AuthRepository _authRepository;
  final SecureStorageService _storage;
  final PrefsService _prefs;

  AppAuthCubit(this._authRepository, this._storage, this._prefs)
    : super(const AppAuthState.initial());

  Future<void> checkAuthStatus() async {
    final timer = AppLogger.startTimer('Auth Status Check', tag: 'Auth');
    final hasToken = await _storage.hasTokens();
    if (!hasToken) {
      await _prefs.clearCachedUser();
      AppLogger.info(
        'No stored tokens found. Emitting unauthenticated.',
        tag: 'Auth',
      );
      timer.stop(note: 'no tokens');
      emit(const AppAuthState.unauthenticated());
      return;
    }

    // 1. Check local cache (Instant Startup)
    final initialCachedUserRaw = _prefs.getCachedUserRaw();
    if (initialCachedUserRaw != null && initialCachedUserRaw.isNotEmpty) {
      try {
        final jsonMap =
            jsonDecode(initialCachedUserRaw) as Map<String, dynamic>;
        User effectiveUser = User.fromJson(jsonMap);
        if (effectiveUser.id.isEmpty) {
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            final sub = JwtUtils.extractUserId(token);
            if (sub != null && sub.isNotEmpty) {
              effectiveUser = effectiveUser.copyWith(id: sub);
              await _prefs.setCachedUserRaw(jsonEncode(effectiveUser.toJson()));
            }
          }
        }
        AppLogger.info(
          '⚡ Local cache hit: authenticated as "${effectiveUser.name}"',
          tag: 'Auth',
        );
        timer.stop(note: 'cache hit - instant');
        emit(AppAuthState.authenticated(effectiveUser));
        return;
      } catch (_) {}
    }

    AppLogger.info(
      '🔄 Tokens found without cache. Migrating by fetching profile from server...',
      tag: 'Auth',
    );

    await safeExecute(
      () async {
        final user = await _authRepository.getCurrentUser();
        await _prefs.setCachedUserRaw(jsonEncode(user.toJson()));
        AppLogger.info(
          '✅ Profile retrieved & cached: "${user.name}"',
          tag: 'Auth',
        );
        timer.stop(note: 'server migration completed');
        emit(AppAuthState.authenticated(user));
        return user;
      },
      onError: (msg) async {
        AppLogger.warning(
          'Failed to fetch profile during migration: $msg',
          tag: 'Auth',
        );
        await _prefs.clearCachedUser();
        timer.stop(note: 'migration failed');
        emit(const AppAuthState.unauthenticated());
      },
      logTag: 'Auth',
    );
  }

  Future<void> syncUser() async {
    AppLogger.debug(
      '🔄 Running background session verification...',
      tag: 'Auth',
    );
    await safeExecute(
      () async {
        final user = await _authRepository.getCurrentUser();
        await _prefs.setCachedUserRaw(jsonEncode(user.toJson()));
        AppLogger.info(
          '✅ Background sync succeeded for "${user.name}"',
          tag: 'Auth',
        );
        emit(AppAuthState.authenticated(user));
        return user;
      },
      onError: (msg) async {
        final hasToken = await _storage.hasTokens();
        if (!hasToken) {
          AppLogger.warning(
            'Session revoked or refresh failed. Emitting unauthenticated.',
            tag: 'Auth',
          );
          await _prefs.clearCachedUser();
          emit(const AppAuthState.unauthenticated());
        } else {
          AppLogger.debug(
            'Background sync skipped/failed (network offline). Keeping cached session.',
            tag: 'Auth',
          );
        }
      },
      logTag: 'Auth',
    );
  }

  void setAuthenticated(User user) {
    AppLogger.info(
      'User authenticated & cached: "${user.name}" (${user.email})',
      tag: 'Auth',
    );
    _prefs.setCachedUserRaw(jsonEncode(user.toJson()));
    emit(AppAuthState.authenticated(user));
  }

  Future<void> logout() async {
    AppLogger.info(
      'Logging out user. Clearing tokens and cached data...',
      tag: 'Auth',
    );
    await safeExecute(
      () async {
        await _authRepository.logout();
        await _prefs.clearCachedUser();
        await _prefs.clearActiveWorkspace();
        emit(const AppAuthState.unauthenticated());
        return true;
      },
      onError: (msg) async {
        await _prefs.clearCachedUser();
        await _prefs.clearActiveWorkspace();
        emit(const AppAuthState.unauthenticated());
      },
      logTag: 'Auth',
    );
  }
}
