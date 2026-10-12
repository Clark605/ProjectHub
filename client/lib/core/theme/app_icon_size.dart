/// Semantic icon size tokens for ProjectHub.
///
/// Centralizes icon dimensions so feature widgets do not hardcode raw numbers
/// in `Icon(..., size: ...)`.
class AppIconSize {
  AppIconSize._();

  /// 12px — Compact badge, tag, and metadata micro-icons.
  static const double xxs = 12;

  /// 14px — Small inline, pill, and filter menu icons.
  static const double xs = 14;

  /// 16px — Secondary action, input suffix, and compact row icons.
  static const double sm = 16;

  /// 18px — Standard list item, card action, and search field icons.
  static const double md = 18;

  /// 20px — Standard toolbar, button, navigation, and form field icons.
  static const double lg = 20;

  /// 24px — Prominent navigation bar, rail, FAB, and header icons.
  static const double xl = 24;

  /// 32px — Feature card, overlay, and section empty-state icons.
  static const double xxl = 32;

  /// 48px — Large empty-state and access-denied illustration icons.
  static const double display = 48;

  /// 64px — Full-screen empty and error state hero icons.
  static const double hero = 64;
}

