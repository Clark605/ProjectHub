import 'package:flutter/material.dart';

class AppSettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  const AppSettingsState({required this.themeMode, required this.locale});

  factory AppSettingsState.initial() =>
      const AppSettingsState(themeMode: ThemeMode.dark, locale: Locale('en'));

  AppSettingsState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsState &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          locale == other.locale;

  @override
  int get hashCode => themeMode.hashCode ^ locale.hashCode;
}
