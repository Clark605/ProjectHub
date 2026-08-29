class AppException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;

  const AppException({
    required this.message,
    this.details,
    this.statusCode,
  });

  @override
  String toString() => 'AppException(statusCode: $statusCode, message: $message, details: $details)';
}

class ServerException extends AppException {
  const ServerException({required super.message, super.details, super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({super.message = 'Unauthorized', super.details, super.statusCode = 401});
}

class ForbiddenException extends AppException {
  const ForbiddenException({super.message = 'Forbidden', super.details, super.statusCode = 403});
}

class NotFoundException extends AppException {
  const NotFoundException({super.message = 'Not found', super.details, super.statusCode = 404});
}

class ValidationException extends AppException {
  const ValidationException({required super.message, super.details, super.statusCode = 400});
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'No internet connection', super.details});
}
