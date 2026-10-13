import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors_extension.dart';

export 'package:client/core/l10n/l10n_extension.dart';
export 'package:client/core/theme/app_colors_extension.dart';

extension AppThemeContextExtensions on BuildContext {
  /// Resolves the current [AppColorsExtension] from theme, falling back to light.
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ??
      AppColorsExtension.light;
}
