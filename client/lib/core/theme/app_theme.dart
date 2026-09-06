import 'package:flutter/material.dart';
import 'package:client/core/theme/dark_theme.dart';
import 'package:client/core/theme/light_theme.dart';

class AppTheme {
  AppTheme._();

  /// Dark theme - primary Stitch Deep Slate design
  static ThemeData get dark => buildDarkTheme();

  /// Light theme - Material 3 light counterpart
  static ThemeData get light => buildLightTheme();
}
