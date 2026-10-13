import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/errors/app_failure.dart';
import 'package:client/core/errors/dio_error_handler.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DioErrorHandler', () {
    RequestOptions requestOptions() => RequestOptions(path: '/test');

    test('ignores generic ProblemDetails title and does not treat it as serverMessage', () {
      final dioException = DioException(
        requestOptions: requestOptions(),
        response: Response(
          requestOptions: requestOptions(),
          statusCode: 404,
          data: {
            'title': 'Not Found',
            'status': 404,
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = DioErrorHandler.handle(dioException);
      expect(exception, isA<NotFoundException>());
      expect(exception.serverMessage, isNull);

      final failure = AppFailure.fromException(exception);
      expect(failure.kind, equals(FailureKind.notFound));
      expect(failure.serverMessage, isNull);
    });

    test('reads explicit Message as serverMessage', () {
      final dioException = DioException(
        requestOptions: requestOptions(),
        response: Response(
          requestOptions: requestOptions(),
          statusCode: 400,
          data: {
            'title': 'One or more validation errors occurred.',
            'Message': 'Workspace name is already taken',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = DioErrorHandler.handle(dioException);
      expect(exception, isA<ValidationException>());
      expect(exception.serverMessage, equals('Workspace name is already taken'));

      final failure = AppFailure.fromException(exception);
      expect(failure.kind, equals(FailureKind.validation));
      expect(failure.serverMessage, equals('Workspace name is already taken'));
      expect(failure.isUserSafe, isTrue);
    });

    test('reads explicit Detail as serverMessage', () {
      final dioException = DioException(
        requestOptions: requestOptions(),
        response: Response(
          requestOptions: requestOptions(),
          statusCode: 403,
          data: {
            'title': 'Forbidden',
            'Detail': 'Only workspace owners can perform this action.',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = DioErrorHandler.handle(dioException);
      expect(exception, isA<ForbiddenException>());
      expect(
        exception.serverMessage,
        equals('Only workspace owners can perform this action.'),
      );

      final failure = AppFailure.fromException(exception);
      expect(failure.kind, equals(FailureKind.forbidden));
      expect(failure.isUserSafe, isTrue);
    });

    test('reads validation errors field as serverMessage', () {
      final dioException = DioException(
        requestOptions: requestOptions(),
        response: Response(
          requestOptions: requestOptions(),
          statusCode: 400,
          data: {
            'title': 'One or more validation errors occurred.',
            'errors': {
              'Email': ['Email is required.'],
            },
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = DioErrorHandler.handle(dioException);
      expect(exception, isA<ValidationException>());
      expect(exception.serverMessage, equals('Email is required.'));

      final failure = AppFailure.fromException(exception);
      expect(failure.kind, equals(FailureKind.validation));
      expect(failure.isUserSafe, isTrue);
    });

    test('409 returns ConflictException and is user-safe in AppFailure', () {
      final dioException = DioException(
        requestOptions: requestOptions(),
        response: Response(
          requestOptions: requestOptions(),
          statusCode: 409,
          data: {
            'Message': 'A workspace with this slug already exists.',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = DioErrorHandler.handle(dioException);
      expect(exception, isA<ConflictException>());
      expect(exception.statusCode, equals(409));
      expect(exception.kind, equals(FailureKind.conflict));
      expect(
        exception.serverMessage,
        equals('A workspace with this slug already exists.'),
      );

      final failure = AppFailure.fromException(exception);
      expect(failure.kind, equals(FailureKind.conflict));
      expect(
        failure.serverMessage,
        equals('A workspace with this slug already exists.'),
      );
      expect(failure.isUserSafe, isTrue);
    });
  });
}

