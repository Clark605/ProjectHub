/// Canonical animation and transition durations across ProjectHub.
class AppDurations {
  AppDurations._();

  /// Snappy micro-interactions (150ms).
  static const Duration fast = Duration(milliseconds: 150);

  /// Standard transitions (200ms - 250ms).
  static const Duration normal = Duration(milliseconds: 250);

  /// Moderate transitions (300ms).
  static const Duration medium = Duration(milliseconds: 300);

  /// Deliberate / expressive transitions (500ms).
  static const Duration slow = Duration(milliseconds: 500);
}
