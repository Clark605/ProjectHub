import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/network/auth_interceptor.dart';

import '../../helpers/mock_repositories.dart';

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

void main() {
  setUpAll(() {
    registerFallbackValue(RequestOptions(path: ''));
  });

  late MockSecureStorageService storage;
  late MockHttpClientAdapter refreshAdapter;
  late AuthInterceptor interceptor;

  Dio createTestDio() {
    final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    dio.httpClientAdapter = refreshAdapter;
    return dio;
  }

  ResponseBody jsonResponse(dynamic data, {int statusCode = 200}) {
    final bytes = utf8.encode(jsonEncode(data));
    return ResponseBody.fromBytes(
      bytes,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  setUp(() {
    storage = MockSecureStorageService();
    refreshAdapter = MockHttpClientAdapter();
    when(() => storage.getAccessToken()).thenAnswer((_) async => null);
    when(() => storage.getRefreshToken()).thenAnswer((_) async => null);
    when(() => storage.clearTokens()).thenAnswer((_) async {});
    when(
      () => storage.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});

    interceptor = AuthInterceptor(
      storage,
      dioFactory: createTestDio,
    );
  });

  group('AuthInterceptor onRequest', () {
    test('adds Authorization header for protected endpoints when token exists', () async {
      when(() => storage.getAccessToken()).thenAnswer((_) async => 'valid-jwt-token');
      final options = RequestOptions(path: '/api/tasks');
      final handler = _CapturingRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(handler.nextOptions?.headers['Authorization'], 'Bearer valid-jwt-token');
    });

    test('does not add Authorization header when token is null', () async {
      when(() => storage.getAccessToken()).thenAnswer((_) async => null);
      final options = RequestOptions(path: '/api/tasks');
      final handler = _CapturingRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(handler.nextOptions?.headers.containsKey('Authorization'), isFalse);
    });

    test('does not add Authorization header for public endpoints', () async {
      when(() => storage.getAccessToken()).thenAnswer((_) async => 'valid-jwt-token');
      final options = RequestOptions(path: ApiConstants.login);
      final handler = _CapturingRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(handler.nextOptions?.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('AuthInterceptor onError pass-through', () {
    test('passes non-401 errors through without attempting refresh', () async {
      final err = DioException(
        requestOptions: RequestOptions(path: '/api/tasks'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/api/tasks'),
        ),
      );
      final handler = _CapturingErrorHandler();

      await interceptor.onError(err, handler);

      expect(handler.wasNextCalled, isTrue);
      expect(handler.nextError, err);
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
      final handler = _CapturingErrorHandler();

      await interceptor.onError(err, handler);

      expect(handler.wasNextCalled, isTrue);
      expect(handler.nextError, err);
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
      final handler = _CapturingErrorHandler();

      await interceptor.onError(err, handler);

      expect(handler.wasNextCalled, isTrue);
      expect(handler.nextError, err);
      verifyNever(() => storage.clearTokens());
    });
  });

  group('AuthInterceptor token refresh & retry', () {
    test('successfully refreshes token and retries failed request', () async {
      when(() => storage.getRefreshToken()).thenAnswer((_) async => 'valid-refresh-token');

      // 1. Refresh endpoint responds with new tokens
      // 2. Retried request responds with 200 OK data
      when(() => refreshAdapter.fetch(any(), any(), any())).thenAnswer((inv) async {
        final options = inv.positionalArguments[0] as RequestOptions;
        if (options.path.contains(ApiConstants.refresh)) {
          return jsonResponse({
            'token': 'new-access-token',
            'refreshToken': 'new-refresh-token',
          });
        }
        return jsonResponse([{'id': 1, 'title': 'Fetched Task'}]);
      });

      final originalRequest = RequestOptions(path: '/api/tasks');
      final err = DioException(
        requestOptions: originalRequest,
        response: Response(statusCode: 401, requestOptions: originalRequest),
      );
      final handler = _CapturingErrorHandler();

      await interceptor.onError(err, handler);

      // Verify tokens were saved
      verify(
        () => storage.saveTokens(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
        ),
      ).called(1);

      // Verify tokens were NOT cleared
      verifyNever(() => storage.clearTokens());

      // Verify original request was retried with new token and resolved
      expect(originalRequest.headers['Authorization'], 'Bearer new-access-token');
      expect(handler.wasResolved, isTrue);
      expect(handler.resolvedResponse?.data, [{'id': 1, 'title': 'Fetched Task'}]);
    });

    test('queues concurrent 401 requests during refresh and replays all with new token', () async {
      when(() => storage.getRefreshToken()).thenAnswer((_) async => 'valid-refresh-token');

      when(() => refreshAdapter.fetch(any(), any(), any())).thenAnswer((inv) async {
        final options = inv.positionalArguments[0] as RequestOptions;
        if (options.path.contains(ApiConstants.refresh)) {
          return jsonResponse({
            'token': 'replayed-token',
            'refreshToken': 'replayed-refresh',
          });
        }
        return jsonResponse({'path': options.path});
      });

      final req1 = RequestOptions(path: '/api/tasks/1');
      final err1 = DioException(
        requestOptions: req1,
        response: Response(statusCode: 401, requestOptions: req1),
      );
      final handler1 = _CapturingErrorHandler();

      final req2 = RequestOptions(path: '/api/tasks/2');
      final err2 = DioException(
        requestOptions: req2,
        response: Response(statusCode: 401, requestOptions: req2),
      );
      final handler2 = _CapturingErrorHandler();

      // Launch first 401, which initiates refresh
      final future1 = interceptor.onError(err1, handler1);
      // Immediately launch second 401 while refresh is in flight (should queue)
      final future2 = interceptor.onError(err2, handler2);

      await Future.wait([future1, future2]);

      expect(handler1.wasResolved, isTrue);
      expect(handler2.wasResolved, isTrue);
      expect(req1.headers['Authorization'], 'Bearer replayed-token');
      expect(req2.headers['Authorization'], 'Bearer replayed-token');
      verify(
        () => storage.saveTokens(
          accessToken: 'replayed-token',
          refreshToken: 'replayed-refresh',
        ),
      ).called(1);
    });

    test('clears tokens and forwards error when refresh call fails', () async {
      when(() => storage.getRefreshToken()).thenAnswer((_) async => 'expired-refresh-token');

      // Refresh call fails with 401
      when(() => refreshAdapter.fetch(any(), any(), any())).thenAnswer((inv) async {
        final options = inv.positionalArguments[0] as RequestOptions;
        if (options.path.contains(ApiConstants.refresh)) {
          throw DioException(
            requestOptions: options,
            response: Response(statusCode: 401, requestOptions: options),
          );
        }
        return jsonResponse({});
      });

      final originalRequest = RequestOptions(path: '/api/tasks');
      final err = DioException(
        requestOptions: originalRequest,
        response: Response(statusCode: 401, requestOptions: originalRequest),
      );
      final handler = _CapturingErrorHandler();

      await interceptor.onError(err, handler);

      // Verify tokens were cleared
      verify(() => storage.clearTokens()).called(1);
      expect(handler.wasNextCalled, isTrue);
    });

    test('does NOT clear tokens when retry of original request fails with 500 error', () async {
      when(() => storage.getRefreshToken()).thenAnswer((_) async => 'valid-refresh-token');

      // Refresh succeeds, but the retried request fails with 500 Internal Server Error
      when(() => refreshAdapter.fetch(any(), any(), any())).thenAnswer((inv) async {
        final options = inv.positionalArguments[0] as RequestOptions;
        if (options.path.contains(ApiConstants.refresh)) {
          return jsonResponse({
            'token': 'new-access-token',
            'refreshToken': 'new-refresh-token',
          });
        }
        throw DioException(
          requestOptions: options,
          response: Response(statusCode: 500, requestOptions: options),
        );
      });

      final originalRequest = RequestOptions(path: '/api/tasks');
      final err = DioException(
        requestOptions: originalRequest,
        response: Response(statusCode: 401, requestOptions: originalRequest),
      );
      final handler = _CapturingErrorHandler();

      await interceptor.onError(err, handler);

      // Tokens were saved
      verify(
        () => storage.saveTokens(
          accessToken: 'new-access-token',
          refreshToken: 'new-refresh-token',
        ),
      ).called(1);

      // CRITICAL: Unrelated retry 500 must NOT clear tokens or log the user out!
      verifyNever(() => storage.clearTokens());
      expect(handler.wasRejected, isTrue);
      expect(handler.rejectedError?.response?.statusCode, 500);
    });
  });
}

class _CapturingRequestHandler extends RequestInterceptorHandler {
  RequestOptions? nextOptions;

  @override
  void next(RequestOptions requestOptions) {
    nextOptions = requestOptions;
  }
}

class _CapturingErrorHandler extends ErrorInterceptorHandler {
  DioException? nextError;
  Response? resolvedResponse;
  DioException? rejectedError;

  bool get wasNextCalled => nextError != null;
  bool get wasResolved => resolvedResponse != null;
  bool get wasRejected => rejectedError != null;

  @override
  void next(DioException err) {
    nextError = err;
  }

  @override
  void resolve(Response response) {
    resolvedResponse = response;
  }

  @override
  void reject(DioException err, [bool callFollowingErrorInterceptor = false]) {
    rejectedError = err;
  }
}
