import 'package:flutter/material.dart';

/// Curated, accessible accent color definitions for workspaces.
///
/// Accent colors provide a subtle wayfinding signal across workspace switcher
/// indicators, sidebar headers, and list markers. They are calibrated for
/// high-contrast legibility in both dark and light modes.
class WorkspaceAccent {
  final String id;
  final String name;
  final Color darkColor;
  final Color lightColor;
  final Color onDark;
  final Color onLight;

  const WorkspaceAccent({
    required this.id,
    required this.name,
    required this.darkColor,
    required this.lightColor,
    this.onDark = Colors.white,
    this.onLight = Colors.white,
  });

  Color resolvedColor(Brightness brightness) =>
      brightness == Brightness.dark ? darkColor : lightColor;

  Color resolvedOnAccent(Brightness brightness) =>
      brightness == Brightness.dark ? onDark : onLight;

  static const teal = WorkspaceAccent(
    id: 'teal',
    name: 'Teal',
    darkColor: Color(0xFF14B8A6),
    lightColor: Color(0xFF0D9488),
  );

  static const blue = WorkspaceAccent(
    id: 'blue',
    name: 'Blue',
    darkColor: Color(0xFF3B82F6),
    lightColor: Color(0xFF2563EB),
  );

  static const indigo = WorkspaceAccent(
    id: 'indigo',
    name: 'Indigo',
    darkColor: Color(0xFF6366F1),
    lightColor: Color(0xFF4F46E5),
  );

  static const violet = WorkspaceAccent(
    id: 'violet',
    name: 'Violet',
    darkColor: Color(0xFF8B5CF6),
    lightColor: Color(0xFF7C3AED),
  );

  static const pink = WorkspaceAccent(
    id: 'pink',
    name: 'Pink',
    darkColor: Color(0xFFEC4899),
    lightColor: Color(0xFFDB2777),
  );

  static const rose = WorkspaceAccent(
    id: 'rose',
    name: 'Rose',
    darkColor: Color(0xFFF43F5E),
    lightColor: Color(0xFFE11D48),
  );

  static const orange = WorkspaceAccent(
    id: 'orange',
    name: 'Orange',
    darkColor: Color(0xFFF97316),
    lightColor: Color(0xFFEA580C),
  );

  static const amber = WorkspaceAccent(
    id: 'amber',
    name: 'Amber',
    darkColor: Color(0xFFF59E0B),
    lightColor: Color(0xFFD97706),
  );

  static const lime = WorkspaceAccent(
    id: 'lime',
    name: 'Lime',
    darkColor: Color(0xFF84CC16),
    lightColor: Color(0xFF65A30D),
  );

  static const cyan = WorkspaceAccent(
    id: 'cyan',
    name: 'Cyan',
    darkColor: Color(0xFF06B6D4),
    lightColor: Color(0xFF0891B2),
  );

  static const List<WorkspaceAccent> values = [
    teal,
    blue,
    indigo,
    violet,
    pink,
    rose,
    orange,
    amber,
    lime,
    cyan,
  ];

  static WorkspaceAccent fromId(String? id) {
    if (id == null || id.trim().isEmpty) return teal;
    final normalized = id.trim().toLowerCase();
    return values.firstWhere((a) => a.id == normalized, orElse: () => teal);
  }
}
