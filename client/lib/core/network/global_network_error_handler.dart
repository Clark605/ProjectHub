import 'dart:async';

import 'package:client/core/errors/app_failure.dart';
import 'package:dio/dio.dart';

class GlobalNetworkErrorHandler extends Interceptor {
  const GlobalNetworkErrorHandler();

  static final _errorStreamController = StreamController<AppFailure>.broadcast();
  static Stream<AppFailure> get onNetworkError => _errorStreamController.stream;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handle(err, handler);
  }

  static void handle(DioException error, ErrorInterceptorHandler handler) {
    final isConnectionFailure = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      _ => false,
    };

    if (isConnectionFailure) {
      _errorStreamController.add(
        const AppFailure(kind: FailureKind.network),
      );
    }

    handler.next(error);
  }
}
