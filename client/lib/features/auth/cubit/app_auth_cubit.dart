import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:client/core/storage/prefs_service.dart';
import 'package:client/core/storage/secure_storage_service.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/user.dart';

@lazySingleton
class AppAuthCubit extends Cubit<AppAuthState> {
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
        final jsonMap = jsonDecode(initialCachedUserRaw) as Map<String, dynamic>;
        User effectiveUser = User.fromJson(jsonMap);
        // Gracefully attach ID from JWT if previously cached without it
        if (effectiveUser.id.isEmpty) {
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            try {
              final decoded = JwtDecoder.decode(token);
              final sub =
                  (decoded['sub'] ??
                          decoded['nameid'] ??
                          decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
                          '')
                      .toString();
              if (sub.isNotEmpty) {
                effectiveUser = effectiveUser.copyWith(id: sub);
                await _prefs.setCachedUserRaw(jsonEncode(effectiveUser.toJson()));
              }
            } catch (_) {
              // Token decode fallback
            }
          }
        }
        AppLogger.info(
          '⚡ Local cache hit: authenticated as "${effectiveUser.name}" (${effectiveUser.email})',
          tag: 'Auth',
        );
        timer.stop(note: 'cache hit - instant');
        emit(AppAuthState.authenticated(effectiveUser));
        return;
      } catch (_) {}
    }

    // 2. Graceful Migration: Tokens exist but no cached user yet (e.g. app update)
    AppLogger.info(
      '🔄 Tokens found without cache. Migrating by fetching profile from server...',
      tag: 'Auth',
    );
    try {
      final user = await _authRepository.getCurrentUser();
      await _prefs.setCachedUserRaw(jsonEncode(user.toJson()));
      AppLogger.info(
        '✅ Profile retrieved & cached: "${user.name}"',
        tag: 'Auth',
      );
      timer.stop(note: 'server migration completed');
      emit(AppAuthState.authenticated(user));
    } catch (e, st) {
      AppLogger.warning(
        'Failed to fetch profile during migration.',
        tag: 'Auth',
        error: e,
        stackTrace: st,
      );
      await _prefs.clearCachedUser();
      timer.stop(note: 'migration failed');
      emit(const AppAuthState.unauthenticated());
    }
  }

  /// Background sync to validate session and refresh cached user profile
  Future<void> syncUser() async {
    AppLogger.debug(
      '🔄 Running background session verification...',
      tag: 'Auth',
    );
    try {
      final user = await _authRepository.getCurrentUser();
      await _prefs.setCachedUserRaw(jsonEncode(user.toJson()));
      AppLogger.info(
        '✅ Background sync succeeded for "${user.name}"',
        tag: 'Auth',
      );
      emit(AppAuthState.authenticated(user));
    } catch (e) {
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
    }
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
    await _authRepository.logout();
    await _prefs.clearCachedUser();
    await _prefs.clearActiveWorkspace();
    emit(const AppAuthState.unauthenticated());
  }
}
