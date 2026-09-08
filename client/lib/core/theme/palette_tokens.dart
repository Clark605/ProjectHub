import 'package:flutter/material.dart';

/// Semantic color tokens required to construct a theme and ambient background.
class PaletteColorTokens {
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color canvasBackground;
  final Color surface;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color border;
  final Color borderVariant;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color error;
  final Color onError;
  final Color orbPrimary;
  final Color orbSecondary;

  const PaletteColorTokens({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.canvasBackground,
    required this.surface,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.border,
    required this.borderVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.error,
    required this.onError,
    required this.orbPrimary,
    required this.orbSecondary,
  });
}
