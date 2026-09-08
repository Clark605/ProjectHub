import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/core/theme/app_palette.dart';
import 'package:client/core/cubit/app_settings_state.dart';

@lazySingleton
class AppSettingsCubit extends Cubit<AppSettingsState> {
  final PrefsService _prefs;

  AppSettingsCubit(this._prefs)
      : super(
          AppSettingsState(
            themeMode: _prefs.getThemeMode(),
            palette: AppPalette.fromId(_prefs.paletteId),
            locale: Locale(_prefs.locale),
          ),
        );

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setThemeMode(mode);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setPalette(AppPalette palette) async {
    await _prefs.setPaletteId(palette.id);
    emit(state.copyWith(palette: palette));
  }

  Future<void> setLocale(Locale locale) async {
    await _prefs.setLocale(locale.languageCode);
    emit(state.copyWith(locale: locale));
  }
}
