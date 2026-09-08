import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/core/storage/secure_storage_service.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/core/utils/jwt_utils.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/auth/data/models/auth_dtos.dart';
import 'package:client/features/auth/data/models/user.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthRepositoryImpl(this._dio, this._storage);

  @override
  Future<User> login(LoginDto dto) async {
    AppLogger.debug('Starting login for ${dto.email}', tag: 'AuthRepository');
    try {
      final response = await _dio.post(ApiConstants.login, data: dto.toJson());

      final authResponse = AuthResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _storage.saveTokens(
        accessToken: authResponse.token,
        refreshToken: authResponse.refreshToken,
      );

      AppLogger.info(
        'Login completed successfully for ${dto.email}',
        tag: 'AuthRepository',
      );
      return await getCurrentUser();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<User> register(RegisterDto dto) async {
    AppLogger.debug(
      'Starting registration for ${dto.email}',
      tag: 'AuthRepository',
    );
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: dto.toJson(),
      );

      final authResponse = AuthResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _storage.saveTokens(
        accessToken: authResponse.token,
        refreshToken: authResponse.refreshToken,
      );

      AppLogger.info(
        'Registration completed successfully for ${dto.email}',
        tag: 'AuthRepository',
      );
      return await getCurrentUser();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<User> getCurrentUser() async {
    AppLogger.debug('Starting getCurrentUser', tag: 'AuthRepository');
    try {
      final response = await _dio.get(ApiConstants.userProfile);
      var user = User.fromJson(response.data as Map<String, dynamic>);

      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        final sub = JwtUtils.extractUserId(token);
        if (sub != null && sub.isNotEmpty) {
          user = user.copyWith(id: sub);
        }
      }

      AppLogger.info(
        'getCurrentUser completed successfully for ${user.email}',
        tag: 'AuthRepository',
      );
      return user;
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<void> logout() async {
    AppLogger.debug('Starting logout', tag: 'AuthRepository');
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _dio.post(
          ApiConstants.logout,
          data: LogoutDto(refreshToken: refreshToken).toJson(),
        );
      }
    } catch (_) {
      // Even if server call fails or offline, local tokens should be cleared
    } finally {
      await _storage.clearTokens();
      AppLogger.info('Logout completed successfully', tag: 'AuthRepository');
    }
  }

  @override
  Future<ForgotPasswordResponseDto> forgotPassword(
    ForgotPasswordDto dto,
  ) async {
    AppLogger.debug(
      'Starting forgotPassword for ${dto.email}',
      tag: 'AuthRepository',
    );
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: dto.toJson(),
      );

      AppLogger.info(
        'forgotPassword completed successfully for ${dto.email}',
        tag: 'AuthRepository',
      );
      return ForgotPasswordResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<void> resetPassword(ResetPasswordDto dto) async {
    AppLogger.debug(
      'Starting resetPassword for ${dto.email}',
      tag: 'AuthRepository',
    );
    try {
      await _dio.post(ApiConstants.resetPassword, data: dto.toJson());
      AppLogger.info(
        'resetPassword completed successfully for ${dto.email}',
        tag: 'AuthRepository',
      );
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<User> updateProfile({required String name, String? bio}) async {
    AppLogger.debug('Starting updateProfile', tag: 'AuthRepository');
    try {
      final response = await _dio.put(
        ApiConstants.userProfile,
        data: {'name': name, 'bio': bio},
      );
      final user = User.fromJson(response.data as Map<String, dynamic>);
      AppLogger.info(
        'updateProfile completed successfully for ${user.email}',
        tag: 'AuthRepository',
      );
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
  }) async {
    AppLogger.debug('Starting externalLogin for $provider', tag: 'AuthRepository');
    try {
      final response = await _dio.post(
        ApiConstants.externalLogin,
        data: {
          'provider': provider,
          'idToken': ?idToken,
          'accessToken': ?accessToken,
        },
      );

      final authResponse = AuthResponseDto.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _storage.saveTokens(
        accessToken: authResponse.token,
        refreshToken: authResponse.refreshToken,
      );

      return await getCurrentUser();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
