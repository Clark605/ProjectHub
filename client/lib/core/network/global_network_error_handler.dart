import 'dart:async';
import 'package:dio/dio.dart';

class GlobalNetworkErrorHandler extends Interceptor {
  const GlobalNetworkErrorHandler();

  static final _errorStreamController = StreamController<String>.broadcast();
  static Stream<String> get onNetworkError => _errorStreamController.stream;

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
        'Unable to connect to the server. Please check that it is running.',
      );
    }

    handler.next(error);
  }
}
