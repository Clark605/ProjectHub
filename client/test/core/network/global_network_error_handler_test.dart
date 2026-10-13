import 'package:client/core/errors/app_failure.dart';
import 'package:client/core/network/global_network_error_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeErrorInterceptorHandler extends ErrorInterceptorHandler {
  DioException? passedError;

  @override
  void next(DioException err) {
    passedError = err;
  }
}

void main() {
  group('GlobalNetworkErrorHandler', () {
    RequestOptions requestOptions() => RequestOptions(path: '/api/test');

    test('emits AppFailure with network kind on connection error', () async {
      final dioException = DioException(
        requestOptions: requestOptions(),
        type: DioExceptionType.connectionError,
      );

      final handler = _FakeErrorInterceptorHandler();

      final expectation = expectLater(
        GlobalNetworkErrorHandler.onNetworkError,
        emits(const AppFailure(kind: FailureKind.network)),
      );

      GlobalNetworkErrorHandler.handle(dioException, handler);
      await expectation;
      expect(handler.passedError, equals(dioException));
    });

    test('does not emit on bad response errors', () async {
      final dioException = DioException(
        requestOptions: requestOptions(),
        type: DioExceptionType.badResponse,
      );

      final handler = _FakeErrorInterceptorHandler();
      bool emitted = false;
      final sub = GlobalNetworkErrorHandler.onNetworkError.listen((_) {
        emitted = true;
      });

      GlobalNetworkErrorHandler.handle(dioException, handler);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(emitted, isFalse);
      expect(handler.passedError, equals(dioException));
      await sub.cancel();
    });
  });
}

