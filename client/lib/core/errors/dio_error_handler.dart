import 'dart:io';

import 'package:dio/dio.dart';

import 'package:client/core/errors/app_exception.dart';

class DioErrorHandler {
  DioErrorHandler._();

  static AppException handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(message: 'Connection timed out');

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return const AppException(message: 'Request was cancelled');

      case DioExceptionType.badCertificate:
        return const AppException(message: 'Bad certificate');

      case DioExceptionType.transformTimeout:
        return const NetworkException(message: 'Transform timed out');

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkException();
        }
        return AppException(
          message: error.message ?? 'An unexpected error occurred',
        );
    }
  }

  static AppException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode;
    final data = response?.data;

    String message = 'Server error';
    String? details;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? message;
      details = data['details'] as String?;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(message: message, details: details);
      case 401:
        return UnauthorizedException(message: message, details: details);
      case 403:
        return ForbiddenException(message: message, details: details);
      case 404:
        return NotFoundException(message: message, details: details);
      default:
        return ServerException(
          message: message,
          details: details,
          statusCode: statusCode,
        );
    }
  }
}
