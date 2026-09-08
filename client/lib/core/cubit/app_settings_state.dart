import 'package:flutter/material.dart';
import 'package:client/core/theme/app_palette.dart';

class AppSettingsState {
  final ThemeMode themeMode;
  final AppPalette palette;
  final Locale locale;

  const AppSettingsState({
    required this.themeMode,
    required this.palette,
    required this.locale,
  });

  factory AppSettingsState.initial() => const AppSettingsState(
        themeMode: ThemeMode.dark,
        palette: AppPalette.deepSlate,
        locale: Locale('en'),
      );

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    AppPalette? palette,
    Locale? locale,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      palette: palette ?? this.palette,
      locale: locale ?? this.locale,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsState &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          palette.id == other.palette.id &&
          locale == other.locale;

  @override
  int get hashCode => themeMode.hashCode ^ palette.id.hashCode ^ locale.hashCode;
}
