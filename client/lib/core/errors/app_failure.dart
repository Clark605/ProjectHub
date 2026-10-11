import 'package:flutter/widgets.dart';
import 'package:client/core/errors/app_exception.dart';
import 'package:client/core/l10n/l10n_extension.dart';
import 'package:client/l10n/generated/app_localizations.dart';

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

/// Represents a typed failure emitted from asynchronous operations.
class AppFailure {
  final FailureKind kind;
  final String? serverMessage;
  final bool isUserSafe;

  const AppFailure({
    required this.kind,
    this.serverMessage,
    this.isUserSafe = true,
  });

  String get message =>
      (isUserSafe && serverMessage != null && serverMessage!.trim().isNotEmpty)
      ? serverMessage!
      : kind.name;

  factory AppFailure.fromException(Object error) {
    if (error is NetworkException) {
      final msg = error.message.trim().isNotEmpty ? error.message : null;
      return AppFailure(
        kind: FailureKind.network,
        serverMessage: msg,
        isUserSafe: msg != null,
      );
    }
    if (error is UnauthorizedException) {
      final msg = error.message.trim().isNotEmpty ? error.message : null;
      return AppFailure(
        kind: FailureKind.unauthorized,
        serverMessage: msg,
        isUserSafe: msg != null,
      );
    }
    if (error is ForbiddenException) {
      final msg = error.message.trim().isNotEmpty ? error.message : null;
      return AppFailure(
        kind: FailureKind.forbidden,
        serverMessage: msg,
        isUserSafe: msg != null,
      );
    }
    if (error is NotFoundException) {
      final msg = error.message.trim().isNotEmpty ? error.message : null;
      return AppFailure(
        kind: FailureKind.notFound,
        serverMessage: msg,
        isUserSafe: msg != null,
      );
    }
    if (error is ValidationException) {
      final msg = error.message.trim().isNotEmpty ? error.message : null;
      return AppFailure(
        kind: FailureKind.validation,
        serverMessage: msg,
        isUserSafe: msg != null,
      );
    }
    if (error is ServerException) {
      final msg = error.message.trim().isNotEmpty ? error.message : null;
      return AppFailure(
        kind: FailureKind.server,
        serverMessage: msg,
        isUserSafe: msg != null,
      );
    }
    if (error is AppException) {
      final msg = error.message.trim().isNotEmpty ? error.message : null;
      return AppFailure(
        kind: FailureKind.server,
        serverMessage: msg,
        isUserSafe: msg != null,
      );
    }
    return const AppFailure(kind: FailureKind.unknown, isUserSafe: false);
  }

  /// Maps the failure into a localized user-facing message string.
  String toLocalizedMessage(AppLocalizations l10n) {
    if (isUserSafe &&
        serverMessage != null &&
        serverMessage!.trim().isNotEmpty) {
      return serverMessage!;
    }
    return switch (kind) {
      FailureKind.network => l10n.connectionErrorMessage,
      FailureKind.unauthorized => l10n.sessionExpiredMessage,
      FailureKind.speechUnavailable => l10n.voiceTaskSpeechUnavailable,
      _ => l10n.error,
    };
  }

  /// Maps the failure into a localized user-facing message using [context].
  String localized(BuildContext context) => toLocalizedMessage(context.l10n);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppFailure &&
          runtimeType == other.runtimeType &&
          kind == other.kind &&
          serverMessage == other.serverMessage &&
          isUserSafe == other.isUserSafe;

  @override
  int get hashCode => Object.hash(kind, serverMessage, isUserSafe);

  @override
  String toString() =>
      'AppFailure(kind: $kind, serverMessage: $serverMessage, isUserSafe: $isUserSafe)';
}
