import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class GlobalNetworkErrorHandler {
  GlobalNetworkErrorHandler._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static bool _isShowingConnectionDialog = false;

  static void handle(DioException error, ErrorInterceptorHandler handler) {
    final isConnectionFailure = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      _ => false,
    };

    if (isConnectionFailure && !_isShowingConnectionDialog) {
      _isShowingConnectionDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = navigatorKey.currentState?.overlay?.context;
        if (context == null) {
          _isShowingConnectionDialog = false;
          return;
        }

        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Connection unavailable'),
            content: const Text(
              'Unable to connect to the server. Please check that it is running.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        ).whenComplete(() => _isShowingConnectionDialog = false);
      });
    }

    handler.next(error);
  }
}
