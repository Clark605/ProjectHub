import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Deep Slate Foundation ──
  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF13131B);
  static const Color surfaceContainer = Color(0xFF1E293B);
  static const Color surfaceContainerHigh = Color(0xFF292932);
  static const Color border = Color(0xFF334155);

  // ── Brand Accents ──
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryContainer = Color(0xFF8083FF);
  static const Color secondary = Color(0xFF38BDF8); // Sky Blue
  static const Color secondaryContainer = Color(0xFF7DD3FC);

  // ── Priority Tokens ──
  static const Color priorityUrgent = Color(0xFFFB7185); // Rose
  static const Color priorityHigh = Color(0xFFF43F5E); // Coral
  static const Color priorityMedium = Color(0xFF38BDF8); // Sky
  static const Color priorityLow = Color(0xFF94A3B8); // Slate

  // ── Status Tokens ──
  static const Color success = Color(0xFF22C55E); // Green
  static const Color warning = Color(0xFFFBBF24); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF38BDF8); // Sky

  // ── Text ──
  static const Color textPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color textTertiary = Color(0xFF64748B); // Slate 500
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Light Theme Overrides ──
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
}
