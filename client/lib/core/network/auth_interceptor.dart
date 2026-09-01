import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/storage/secure_storage_service.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
  _pendingRequests = [];

  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints
    final publicPaths = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.refresh,
    ];

    if (!publicPaths.contains(options.path)) {
      final token = await _secureStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final publicPaths = [
      ApiConstants.login,
      ApiConstants.register,
      ApiConstants.refresh,
      ApiConstants.forgotPassword,
      ApiConstants.resetPassword,
    ];

    // Don't retry public auth endpoints
    if (publicPaths.contains(err.requestOptions.path)) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      // Queue the request while refresh is in progress
      _pendingRequests.add((options: err.requestOptions, handler: handler));
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        _rejectAll(err);
        return handler.next(err);
      }

      // Use a fresh Dio instance to avoid interceptor loop
      final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

      final response = await refreshDio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      final newToken = response.data['token'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      await _secureStorage.saveTokens(
        accessToken: newToken,
        refreshToken: newRefreshToken,
      );

      // Retry the original failed request
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final retryDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      final retryResponse = await retryDio.fetch(err.requestOptions);
      handler.resolve(retryResponse);

      // Replay queued requests
      _replayAll(newToken);
    } on DioException {
      // Refresh failed — clear tokens and reject everything
      await _secureStorage.clearTokens();
      _rejectAll(err);
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _replayAll(String newToken) {
    for (final pending in _pendingRequests) {
      pending.options.headers['Authorization'] = 'Bearer $newToken';
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
      dio
          .fetch(pending.options)
          .then(
            (response) => pending.handler.resolve(response),
            onError: (error) => pending.handler.reject(error as DioException),
          );
    }
    _pendingRequests.clear();
  }

  void _rejectAll(DioException error) {
    for (final pending in _pendingRequests) {
      pending.handler.next(error);
    }
    _pendingRequests.clear();
  }
}
