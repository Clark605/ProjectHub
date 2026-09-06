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

    String? message;
    String? details;

    if (data is String && data.trim().isNotEmpty) {
      message = data.trim();
    } else if (data is Map<String, dynamic>) {
      message =
          data['message'] as String? ??
          data['title'] as String? ??
          data['detail'] as String?;
      details = data['details'] as String?;

      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final firstList = errors.values.firstOrNull;
        if (firstList is List && firstList.isNotEmpty) {
          message = firstList.first.toString();
        }
      }
    }

    final defaultMessage = switch (statusCode) {
      400 => 'Bad request',
      401 => 'Authentication required',
      403 => 'You do not have permission to perform this action',
      404 => 'Requested resource not found',
      409 => 'A conflict occurred',
      500 => 'Internal server error',
      _ => 'Server error (${statusCode ?? 'unknown'})',
    };

    final finalMessage = (message != null && message.isNotEmpty)
        ? message
        : defaultMessage;

    switch (statusCode) {
      case 400:
        return ValidationException(message: finalMessage, details: details);
      case 401:
        return UnauthorizedException(message: finalMessage, details: details);
      case 403:
        return ForbiddenException(message: finalMessage, details: details);
      case 404:
        return NotFoundException(message: finalMessage, details: details);
      default:
        return ServerException(
          message: finalMessage,
          details: details,
          statusCode: statusCode,
        );
    }
  }
}
