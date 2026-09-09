import 'package:flutter/material.dart';
import 'package:client/core/theme/app_typography.dart';
import 'package:client/core/theme/palette_tokens.dart';
import 'package:client/core/theme/palette_definitions.dart';

class AppPalette {
  final String id;
  final String name;
  final String description;
  final PaletteColorTokens dark;
  final PaletteColorTokens light;

  const AppPalette({
    required this.id,
    required this.name,
    required this.description,
    required this.dark,
    required this.light,
  });

  static const deepSlate = AppPalette(
    id: 'deepSlate',
    name: 'Deep Slate',
    description: 'Electric Violet & Sky Blue cyberpunk high contrast',
    dark: PaletteDefinitions.deepSlateDark,
    light: PaletteDefinitions.deepSlateLight,
  );

  static const oceanBreeze = AppPalette(
    id: 'oceanBreeze',
    name: 'Ocean Breeze',
    description: 'Calm Blue & Mint Emerald focused clarity',
    dark: PaletteDefinitions.oceanBreezeDark,
    light: PaletteDefinitions.oceanBreezeLight,
  );

  static const sunsetEmber = AppPalette(
    id: 'sunsetEmber',
    name: 'Sunset Ember',
    description: 'Warm Orange & Neon Pink high energy',
    dark: PaletteDefinitions.sunsetEmberDark,
    light: PaletteDefinitions.sunsetEmberLight,
  );

  static const forestMoss = AppPalette(
    id: 'forestMoss',
    name: 'Forest Moss',
    description: 'Lush Green & Lime Pop natural grounded calm',
    dark: PaletteDefinitions.forestMossDark,
    light: PaletteDefinitions.forestMossLight,
  );

  static const roseGold = AppPalette(
    id: 'roseGold',
    name: 'Rose Gold',
    description: 'Muted Rose & Warm Amber elegant luxury',
    dark: PaletteDefinitions.roseGoldDark,
    light: PaletteDefinitions.roseGoldLight,
  );

  static const midnightPurple = AppPalette(
    id: 'midnightPurple',
    name: 'Midnight Purple',
    description: 'Vibrant Purple & Soft Indigo sleek neon',
    dark: PaletteDefinitions.midnightPurpleDark,
    light: PaletteDefinitions.midnightPurpleLight,
  );

  static const List<AppPalette> values = [
    deepSlate,
    oceanBreeze,
    sunsetEmber,
    forestMoss,
    roseGold,
    midnightPurple,
  ];

  static AppPalette fromId(String? id) {
    if (id == null) return deepSlate;
    return values.firstWhere(
      (p) => p.id == id,
      orElse: () => deepSlate,
    );
  }

  PaletteColorTokens tokens(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  ThemeData toThemeData(Brightness brightness) {
    final t = tokens(brightness);
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: t.primary,
      onPrimary: t.onPrimary,
      primaryContainer: t.primaryContainer,
      onPrimaryContainer: t.onPrimary,
      secondary: t.secondary,
      onSecondary: t.onSecondary,
      secondaryContainer: t.secondaryContainer,
      onSecondaryContainer: t.onSecondary,
      surface: t.surface,
      onSurface: t.textPrimary,
      onSurfaceVariant: t.textSecondary,
      surfaceContainerLowest: isDark ? const Color(0xFF0D0D15) : Colors.white,
      surfaceContainerLow: t.surface,
      surfaceContainer: t.surfaceContainer,
      surfaceContainerHigh: t.surfaceContainerHigh,
      surfaceContainerHighest: t.borderVariant,
      outline: t.border,
      outlineVariant: t.borderVariant,
      error: t.error,
      onError: t.onError,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: t.canvasBackground,
      colorScheme: colorScheme,
      fontFamily: 'Inter',
      textTheme: AppTypography.textTheme.apply(
        bodyColor: t.textPrimary,
        displayColor: t.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: t.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: t.border, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: t.textPrimary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: t.borderVariant,
        thickness: 1,
        space: 1,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: t.surface,
        elevation: 0,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: t.surface,
        selectedItemColor: t.primary,
        unselectedItemColor: t.textSecondary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.surface,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.surfaceContainer,
        side: BorderSide(color: t.borderVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
