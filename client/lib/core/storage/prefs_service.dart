import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/core/constants/storage_keys.dart';
import 'package:client/features/auth/data/models/user.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';

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

  WorkspaceDto? getCachedActiveWorkspace() {
    final jsonStr = _prefs.getString(StorageKeys.cachedActiveWorkspace);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return WorkspaceDto.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheActiveWorkspace(WorkspaceDto workspace) => _prefs.setString(
    StorageKeys.cachedActiveWorkspace,
    jsonEncode(workspace.toJson()),
  );

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
  User? getCachedUser() {
    final jsonStr = _prefs.getString(StorageKeys.cachedUser);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
      return User.fromJson(jsonMap);
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheUser(User user) =>
      _prefs.setString(StorageKeys.cachedUser, jsonEncode(user.toJson()));

  Future<void> clearCachedUser() => _prefs.remove(StorageKeys.cachedUser);
}

@module
abstract class PrefsModule {
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
