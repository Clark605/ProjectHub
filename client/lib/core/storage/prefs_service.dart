import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/constants/storage_keys.dart';

@lazySingleton
class PrefsService {
  final SharedPreferences _prefs;

  PrefsService(this._prefs);

  // Theme Mode
  ThemeMode getThemeMode() {
    final value = _prefs.getString(StorageKeys.themeMode);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.dark, // Default to dark (Stitch design)
    };
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(StorageKeys.themeMode, mode.name);

  // Onboarding
  bool get hasSeenOnboarding =>
      _prefs.getBool(StorageKeys.onboardingSeen) ?? false;

  Future<void> setOnboardingSeen() =>
      _prefs.setBool(StorageKeys.onboardingSeen, true);

  // Active Workspace
  int? get activeWorkspaceId =>
      _prefs.getInt(StorageKeys.activeWorkspaceId);

  Future<void> setActiveWorkspaceId(int id) =>
      _prefs.setInt(StorageKeys.activeWorkspaceId, id);

  Future<void> clearActiveWorkspace() =>
      _prefs.remove(StorageKeys.activeWorkspaceId);

  // Locale
  String get locale => _prefs.getString(StorageKeys.locale) ?? 'en';

  Future<void> setLocale(String locale) =>
      _prefs.setString(StorageKeys.locale, locale);
}

@module
abstract class PrefsModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
