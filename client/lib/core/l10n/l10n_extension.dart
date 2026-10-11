import 'package:flutter/widgets.dart';
import 'package:client/l10n/generated/app_localizations.dart';

extension AppContextExtensions on BuildContext {
  /// Provides direct, non-nullable access to [AppLocalizations].
  AppLocalizations get l10n => AppLocalizations.of(this);
}
