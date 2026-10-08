import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/storage/secure_storage_service.dart';

@lazySingleton
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final Dio Function() _dioFactory;

  static final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();
  static Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  static DateTime? _lastSessionExpiredNotification;

  static void notifySessionExpired() {
    final now = DateTime.now();
    if (_lastSessionExpiredNotification != null &&
        now.difference(_lastSessionExpiredNotification!).inMilliseconds <
            1000) {
      return;
    }
    _lastSessionExpiredNotification = now;
    _sessionExpiredController.add(null);
  }

  @visibleForTesting
  static void resetSessionExpiredThrottle() {
    _lastSessionExpiredNotification = null;
  }

  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
  _pendingRequests = [];

  AuthInterceptor(this._secureStorage, {Dio Function()? dioFactory})
    : _dioFactory =
          dioFactory ?? (() => Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)));

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
      ApiConstants.externalLogin,
      ApiConstants.forgotPassword,
      ApiConstants.resetPassword,
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
      ApiConstants.externalLogin,
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

    final String newToken;
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        notifySessionExpired();
        _rejectAll(err);
        _isRefreshing = false;
        return handler.next(err);
      }

      // Use a fresh Dio instance to avoid interceptor loop
      final refreshDio = _dioFactory();

      final response = await refreshDio.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );

      final tokenData = response.data;
      if (tokenData is! Map<String, dynamic> ||
          tokenData['token'] is! String ||
          tokenData['refreshToken'] is! String) {
        throw const FormatException('Invalid refresh response payload');
      }

      newToken = tokenData['token'] as String;
      final newRefreshToken = tokenData['refreshToken'] as String;

      await _secureStorage.saveTokens(
        accessToken: newToken,
        refreshToken: newRefreshToken,
      );
    } catch (refreshErr) {
      // Clear tokens only on a real auth/payload invalidation, not on transient network/timeout failures
      final status = refreshErr is DioException
          ? refreshErr.response?.statusCode
          : null;
      if (refreshErr is FormatException ||
          status == 400 ||
          status == 401 ||
          status == 403) {
        await _secureStorage.clearTokens();
        notifySessionExpired();
      }

      final dioError = refreshErr is DioException
          ? refreshErr
          : DioException(requestOptions: err.requestOptions, error: refreshErr);
      _rejectAll(dioError);
      _isRefreshing = false;
      return handler.next(dioError);
    }

    // Refresh succeeded! Retry the original failed request
    try {
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final retryDio = _dioFactory();
      final retryResponse = await retryDio.fetch(err.requestOptions);
      handler.resolve(retryResponse);
    } on DioException catch (retryErr) {
      // Unrelated retry failure must NOT clear tokens or log the user out
      if (retryErr.response?.statusCode == 401) {
        await _secureStorage.clearTokens();
        notifySessionExpired();
      }
      handler.reject(retryErr);
    } catch (e) {
      handler.reject(
        DioException(requestOptions: err.requestOptions, error: e),
      );
    } finally {
      // Replay queued requests and eliminate hang window for requests arriving during replay
      while (_pendingRequests.isNotEmpty) {
        await _replayAll(newToken);
      }
      _isRefreshing = false;
    }
  }

  Future<void> _replayAll(String newToken) async {
    final pendingCopy = List.of(_pendingRequests);
    _pendingRequests.clear();
    await Future.wait(
      pendingCopy.map((pending) async {
        pending.options.headers['Authorization'] = 'Bearer $newToken';
        final dio = _dioFactory();
        try {
          final response = await dio.fetch(pending.options);
          pending.handler.resolve(response);
        } on DioException catch (e) {
          if (e.response?.statusCode == 401) {
            await _secureStorage.clearTokens();
            notifySessionExpired();
          }
          pending.handler.reject(e);
        } catch (e) {
          pending.handler.reject(
            DioException(requestOptions: pending.options, error: e),
          );
        }
      }),
    );
  }

  void _rejectAll(DioException error) {
    for (final pending in _pendingRequests) {
      pending.handler.next(error);
    }
    _pendingRequests.clear();
  }
}
