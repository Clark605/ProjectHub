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
  int? get activeWorkspaceId => _prefs.getInt(StorageKeys.activeWorkspaceId);

  Future<void> setActiveWorkspaceId(int id) =>
      _prefs.setInt(StorageKeys.activeWorkspaceId, id);

  String? getCachedActiveWorkspaceRaw() {
    return _prefs.getString(StorageKeys.cachedActiveWorkspace);
  }

  Future<void> setCachedActiveWorkspaceRaw(String workspaceJson) =>
      _prefs.setString(StorageKeys.cachedActiveWorkspace, workspaceJson);

  Future<void> clearCachedActiveWorkspace() =>
      _prefs.remove(StorageKeys.cachedActiveWorkspace);

  Future<void> clearActiveWorkspace() async {
    await _prefs.remove(StorageKeys.activeWorkspaceId);
    await _prefs.remove(StorageKeys.cachedActiveWorkspace);
  }

  // Locale
  String get locale => _prefs.getString(StorageKeys.locale) ?? 'en';

  Future<void> setLocale(String locale) =>
      _prefs.setString(StorageKeys.locale, locale);

  // Cached User Profile
  String? getCachedUserRaw() {
    return _prefs.getString(StorageKeys.cachedUser);
  }

  Future<void> setCachedUserRaw(String userJson) =>
      _prefs.setString(StorageKeys.cachedUser, userJson);

  Future<void> clearCachedUser() => _prefs.remove(StorageKeys.cachedUser);
}

@module
abstract class PrefsModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
