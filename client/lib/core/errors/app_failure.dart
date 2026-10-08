import 'package:client/core/errors/app_exception.dart';
import 'package:client/l10n/generated/app_localizations.dart';

enum FailureKind {
  network,
  unauthorized,
  forbidden,
  notFound,
  validation,
  server,
  unknown,
}

/// Represents a typed failure emitted from asynchronous operations.
class AppFailure {
  final FailureKind kind;
  final String? serverMessage;

  const AppFailure({required this.kind, this.serverMessage});

  String get message => serverMessage ?? kind.name;

  factory AppFailure.fromException(Object error) {
    if (error is NetworkException) {
      return AppFailure(
        kind: FailureKind.network,
        serverMessage: error.message,
      );
    }
    if (error is UnauthorizedException) {
      return AppFailure(
        kind: FailureKind.unauthorized,
        serverMessage: error.message,
      );
    }
    if (error is ForbiddenException) {
      return AppFailure(
        kind: FailureKind.forbidden,
        serverMessage: error.message,
      );
    }
    if (error is NotFoundException) {
      return AppFailure(
        kind: FailureKind.notFound,
        serverMessage: error.message,
      );
    }
    if (error is ValidationException) {
      return AppFailure(
        kind: FailureKind.validation,
        serverMessage: error.message,
      );
    }
    if (error is ServerException) {
      return AppFailure(kind: FailureKind.server, serverMessage: error.message);
    }
    if (error is AppException) {
      return AppFailure(kind: FailureKind.server, serverMessage: error.message);
    }
    final msg = error is Exception
        ? error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '')
        : null;
    return AppFailure(kind: FailureKind.unknown, serverMessage: msg);
  }

  /// Maps the failure into a localized user-facing message string.
  String toLocalizedMessage(AppLocalizations l10n) {
    if (serverMessage != null && serverMessage!.trim().isNotEmpty) {
      return serverMessage!;
    }
    return switch (kind) {
      FailureKind.network => l10n.connectionErrorMessage,
      FailureKind.unauthorized => l10n.sessionExpiredTitle,
      _ => l10n.error,
    };
  }
}
