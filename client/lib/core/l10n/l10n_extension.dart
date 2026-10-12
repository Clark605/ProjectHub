import 'package:flutter/widgets.dart';
import 'package:client/core/errors/app_failure.dart';
import 'package:client/l10n/generated/app_localizations.dart';

extension AppContextExtensions on BuildContext {
  /// Provides direct, non-nullable access to [AppLocalizations].
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppFailureL10n on AppFailure {
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
      FailureKind.forbidden => l10n.forbiddenErrorMessage,
      FailureKind.notFound => l10n.notFoundErrorMessage,
      FailureKind.validation => l10n.validationErrorMessage,
      FailureKind.server => l10n.serverErrorMessage,
      FailureKind.speechUnavailable => l10n.voiceTaskSpeechUnavailable,
      FailureKind.unknown => l10n.error,
    };
  }

  /// Maps the failure into a localized user-facing message using [context].
  String localized(BuildContext context) => toLocalizedMessage(context.l10n);
}
