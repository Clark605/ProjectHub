import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/core/services/github_auth_service.dart';
import 'package:client/core/services/google_auth_service.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/core/storage/secure_storage_service.dart';
import 'package:client/core/utils/jwt_utils.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/auth_social_mixin.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';
import 'package:client/features/auth/data/models/user.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl with AuthSocialMixin implements AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;
  final PrefsService _prefs;
  @override
  final GoogleAuthService googleAuthService;
  @override
  final GithubAuthService githubAuthService;

  final _authStateController = StreamController<User?>.broadcast();

  AuthRepositoryImpl(
    this._dio,
    this._storage,
    this._prefs,
    this.googleAuthService,
    this.githubAuthService,
  );

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<User?> restoreSession() async {
    if (!await _storage.hasTokens()) {
      await _prefs.clearCachedUser();
      _authStateController.add(null);
      return null;
    }
    final cached = _prefs.getCachedUserRaw();
    if (cached != null && cached.isNotEmpty) {
      try {
        var user = User.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        if (user.id.isEmpty) {
          final token = await _storage.getAccessToken();
          if (token != null) {
            final sub = JwtUtils.extractUserId(token);
            if (sub != null) user = user.copyWith(id: sub);
          }
        }
        await _prefs.setCachedUserRaw(jsonEncode(user.toJson()));
        _authStateController.add(user);
        return user;
      } catch (_) {}
    }
    try {
      final user = await getCurrentUser();
      await _prefs.setCachedUserRaw(jsonEncode(user.toJson()));
      _authStateController.add(user);
      return user;
    } catch (_) {
      await _prefs.clearCachedUser();
      _authStateController.add(null);
      return null;
    }
  }

  Future<User> _processAuthSuccess(Response res) async {
    final auth = AuthResponseDto.fromJson(res.data as Map<String, dynamic>);
    await _storage.saveTokens(accessToken: auth.token, refreshToken: auth.refreshToken);
    final user = await getCurrentUser();
    setAuthenticated(user);
    return user;
  }

  @override
  Future<User> login(LoginDto dto) async {
    try {
      final res = await _dio.post(ApiConstants.login, data: dto.toJson());
      return await _processAuthSuccess(res);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<User> register(RegisterDto dto) async {
    try {
      final res = await _dio.post(ApiConstants.register, data: dto.toJson());
      return await _processAuthSuccess(res);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final res = await _dio.get(ApiConstants.userProfile);
      var user = User.fromJson(res.data as Map<String, dynamic>);
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final sub = JwtUtils.extractUserId(token);
        if (sub != null && sub.isNotEmpty) user = user.copyWith(id: sub);
      }
      return user;
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final rt = await _storage.getRefreshToken();
      if (rt != null && rt.isNotEmpty) {
        await _dio.post(ApiConstants.logout, data: LogoutDto(refreshToken: rt).toJson());
      }
    } catch (_) {}
    await _storage.clearTokens();
    await _prefs.clearCachedUser();
    await _prefs.clearActiveWorkspace();
    _authStateController.add(null);
  }

  @override
  Future<ForgotPasswordResponseDto> forgotPassword(ForgotPasswordDto dto) async {
    try {
      final res = await _dio.post(ApiConstants.forgotPassword, data: dto.toJson());
      return ForgotPasswordResponseDto.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordDto dto) async {
    try {
      await _dio.post(ApiConstants.resetPassword, data: dto.toJson());
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<User> updateProfile({required String name, String? bio}) async {
    try {
      final res = await _dio.put(ApiConstants.userProfile, data: {'name': name, 'bio': bio});
      final user = User.fromJson(res.data as Map<String, dynamic>);
      setAuthenticated(user);
      return user;
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<User> externalLogin({
    required String provider,
    String? idToken,
    String? accessToken,
    String? code,
    String? redirectUri,
  }) async {
    try {
      final res = await _dio.post(ApiConstants.externalLogin, data: {
        'provider': provider,
        'idToken': ?idToken,
        'accessToken': ?accessToken,
        'code': ?code,
        'redirectUri': ?redirectUri,
      });
      return await _processAuthSuccess(res);
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  void setAuthenticated(User user) {
    _prefs.setCachedUserRaw(jsonEncode(user.toJson()));
    _authStateController.add(user);
  }
}
