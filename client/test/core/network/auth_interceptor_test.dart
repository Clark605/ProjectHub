import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/network/auth_interceptor.dart';
import 'package:client/core/storage/secure_storage_service.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorageService storage;
  late AuthInterceptor interceptor;

  setUp(() {
    storage = MockSecureStorageService();
    when(() => storage.getAccessToken()).thenAnswer((_) async => null);
    when(() => storage.getRefreshToken()).thenAnswer((_) async => null);
    when(() => storage.clearTokens()).thenAnswer((_) async {});
    when(
      () => storage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
    interceptor = AuthInterceptor(storage);
  });

  group('AuthInterceptor onRequest', () {
    test('adds Authorization header for protected endpoints when token exists', () async {
      when(() => storage.getAccessToken()).thenAnswer((_) async => 'valid-jwt-token');
      final options = RequestOptions(path: '/api/tasks');

      RequestOptions? interceptedOptions;
      interceptor.onRequest(
        options,
        _MockRequestHandler((opts) {
          interceptedOptions = opts;
        }),
      );

      await Future<void>.delayed(Duration.zero);
      expect(interceptedOptions?.headers['Authorization'], 'Bearer valid-jwt-token');
    });

    test('does not add Authorization header when token is null', () async {
      when(() => storage.getAccessToken()).thenAnswer((_) async => null);
      final options = RequestOptions(path: '/api/tasks');

      RequestOptions? interceptedOptions;
      interceptor.onRequest(
        options,
        _MockRequestHandler((opts) {
          interceptedOptions = opts;
        }),
      );

      await Future<void>.delayed(Duration.zero);
      expect(interceptedOptions?.headers.containsKey('Authorization'), isFalse);
    });

    test('does not add Authorization header for public endpoints', () async {
      when(() => storage.getAccessToken()).thenAnswer((_) async => 'valid-jwt-token');
      final options = RequestOptions(path: ApiConstants.login);

      RequestOptions? interceptedOptions;
      interceptor.onRequest(
        options,
        _MockRequestHandler((opts) {
          interceptedOptions = opts;
        }),
      );

      await Future<void>.delayed(Duration.zero);
      expect(interceptedOptions?.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('AuthInterceptor onError', () {
    test('passes non-401 errors through without attempting refresh', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/tasks'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/api/tasks'),
        ),
      );

      DioException? passedErr;
      await interceptor.onError(
        err,
        _MockErrorHandler(onNext: (e) {
          passedErr = e;
        }),
      );

      expect(passedErr, err);
      verifyNever(() => storage.clearTokens());
    });

    test('passes 401 on public endpoints through without retry', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: ApiConstants.login),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: ApiConstants.login),
        ),
      );

      DioException? passedErr;
      await interceptor.onError(
        err,
        _MockErrorHandler(onNext: (e) {
          passedErr = e;
        }),
      );

      expect(passedErr, err);
      verifyNever(() => storage.clearTokens());
    });

    test('rejects and passes through when refresh token is null', () async {
      when(() => storage.getRefreshToken()).thenAnswer((_) async => null);
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/tasks'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/api/tasks'),
        ),
      );

      DioException? passedErr;
      await interceptor.onError(
        err,
        _MockErrorHandler(onNext: (e) {
          passedErr = e;
        }),
      );

      expect(passedErr, err);
    });
  });
}

class _MockRequestHandler extends RequestInterceptorHandler {
  final void Function(RequestOptions) onNextCallback;
  _MockRequestHandler(this.onNextCallback);

  @override
  void next(RequestOptions requestOptions) {
    onNextCallback(requestOptions);
  }
}

class _MockErrorHandler extends ErrorInterceptorHandler {
  final void Function(DioException)? onNext;

  _MockErrorHandler({this.onNext});

  @override
  void next(DioException err) {
    onNext?.call(err);
  }

  @override
  void resolve(Response response) {}

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) {}
}
