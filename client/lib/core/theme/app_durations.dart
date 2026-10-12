/// Canonical animation and transition durations across ProjectHub.
class AppDurations {
  AppDurations._();

  /// Snappy micro-interactions (150ms).
  static const Duration fast = Duration(milliseconds: 150);

  /// Standard transitions (200ms - 250ms).
  static const Duration normal = Duration(milliseconds: 250);

  /// Moderate transitions and debounce timers (300ms).
  static const Duration medium = Duration(milliseconds: 300);

  /// Deliberate / expressive transitions (500ms).
  static const Duration slow = Duration(milliseconds: 500);

  /// Continuous pulse / breathing animations (600ms).
  static const Duration pulse = Duration(milliseconds: 600);

  /// Long ambient loop animations (3200ms).
  static const Duration ambientLoop = Duration(milliseconds: 3200);

  /// Dynamic millisecond duration for parameterized stagger delays.
  static Duration ms(int milliseconds) => Duration(milliseconds: milliseconds);
}
