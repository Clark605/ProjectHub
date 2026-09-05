import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:jwt_decoder/jwt_decoder.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:client/core/storage/secure_storage_service.dart';
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
    try {
      final response = await _dio.post(ApiConstants.login, data: dto.toJson());

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

  @override
  Future<User> register(RegisterDto dto) async {
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

      return await getCurrentUser();
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConstants.userProfile);
      var user = User.fromJson(response.data as Map<String, dynamic>);

      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        try {
          final decoded = JwtDecoder.decode(token);
          final sub = (decoded['sub'] ??
                  decoded['nameid'] ??
                  decoded[
                      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
                  '')
              .toString();
          if (sub.isNotEmpty) {
            user = user.copyWith(id: sub);
          }
        } catch (_) {
          // Token decode fallback
        }
      }

      return user;
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }

  @override
  Future<void> logout() async {
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
    }
  }

  @override
  Future<ForgotPasswordResponseDto> forgotPassword(
    ForgotPasswordDto dto,
  ) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: dto.toJson(),
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
    try {
      await _dio.post(ApiConstants.resetPassword, data: dto.toJson());
    } on DioException catch (e) {
      throw DioErrorHandler.handle(e);
    }
  }
}
