import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Deep Slate Foundation ──
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF13131B);
  static const Color surfaceDim = Color(0xFF13131B);
  static const Color surfaceBright = Color(0xFF393841);
  static const Color surfaceContainerLowest = Color(0xFF0D0D15);
  static const Color surfaceContainerLow = Color(0xFF1B1B23);
  static const Color surfaceContainer = Color(0xFF1F1F27);
  static const Color surfaceContainerHigh = Color(0xFF292932);
  static const Color surfaceContainerHighest = Color(0xFF34343D);
  static const Color border = Color(0xFF334155);
  static const Color borderVariant = Color(0xFF464554);

  // ── Electric Violet & Sky Blue Ambient / Accent Tokens ──
  static const Color electricViolet = Color(0xFFC0C1FF);
  static const Color onElectricViolet = Color(0xFF1000A9);
  static const Color electricVioletContainer = Color(0xFF8083FF);
  static const Color onElectricVioletContainer = Color(0xFF0D0096);

  static const Color skyBlue = Color(0xFF89CEFF);
  static const Color onSkyBlue = Color(0xFF00344D);
  static const Color skyBlueContainer = Color(0xFF00A2E6);

  // ── Brand Accents ──
  static const Color primary = Color(0xFFC0C1FF); // Electric Violet primary
  static const Color primaryContainer = Color(0xFF8083FF);
  static const Color secondary = Color(0xFF89CEFF); // Sky Blue secondary
  static const Color secondaryContainer = Color(0xFF00A2E6);

  // ── Priority Tokens ──
  static const Color priorityUrgent = Color(0xFFFB7185); // Rose
  static const Color priorityHigh = Color(0xFFF43F5E); // Coral
  static const Color priorityMedium = Color(0xFF38BDF8); // Sky
  static const Color priorityLow = Color(0xFF94A3B8); // Slate

  // ── Status Tokens ──
  static const Color success = Color(0xFF22C55E); // Green
  static const Color warning = Color(0xFFFBBF24); // Amber
  static const Color error = Color.fromARGB(255, 255, 65, 44); // Red / Coral
  static const Color onError = Color(0xFF690005);
  static const Color info = Color(0xFF89CEFF); // Sky

  // ── Text ──
  static const Color textPrimary = Color(0xFFE4E1ED); // Soft high-contrast text
  static const Color textSecondary = Color(0xFF908FA0); // Muted slate / outline
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textOnPrimary = Color(
    0xFF1000A9,
  ); // Dark contrast on electric violet

  // ── Light Theme Overrides ──
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
}
