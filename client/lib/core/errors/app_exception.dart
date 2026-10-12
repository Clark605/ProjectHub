enum FailureKind {
  network,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  speechUnavailable,
  unknown,
}

class AppException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;

  const AppException({required this.message, this.details, this.statusCode});

  FailureKind get kind => FailureKind.server;

  @override
  String toString() =>
      'AppException(statusCode: $statusCode, message: $message, details: $details)';
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.details,
    super.statusCode,
  });

  @override
  FailureKind get kind => FailureKind.server;
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized',
    super.details,
    super.statusCode = 401,
  });

  @override
  FailureKind get kind => FailureKind.unauthorized;
}

class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'Forbidden',
    super.details,
    super.statusCode = 403,
  });

  @override
  FailureKind get kind => FailureKind.forbidden;
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Not found',
    super.details,
    super.statusCode = 404,
  });

  @override
  FailureKind get kind => FailureKind.notFound;
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.details,
    super.statusCode = 400,
  });

  @override
  FailureKind get kind => FailureKind.validation;
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.details,
  });

  @override
  FailureKind get kind => FailureKind.network;
}
