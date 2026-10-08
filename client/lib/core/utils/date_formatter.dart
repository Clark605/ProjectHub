import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class DateFormatter {
  DateFormatter._();

  static String? _resolveLocale(BuildContext? context) {
    if (context == null) return null;
    return Localizations.maybeLocaleOf(context)?.toString();
  }

  /// Formats date as 'MMM d, yyyy' (e.g. 'Oct 14, 2026')
  static String formatDate(
    DateTime? date, {
    BuildContext? context,
    String fallback = '',
  }) {
    if (date == null) return fallback;
    final locale = _resolveLocale(context);
    return DateFormat.yMMMd(locale).format(date.toLocal());
  }

  /// Formats date as 'MMM d' (e.g. 'Oct 14')
  static String formatShortDate(
    DateTime? date, {
    BuildContext? context,
    String fallback = '',
  }) {
    if (date == null) return fallback;
    final locale = _resolveLocale(context);
    return DateFormat.MMMd(locale).format(date.toLocal());
  }

  /// Formats date as 'MMMM d, yyyy' (e.g. 'October 14, 2026')
  static String formatFullDate(
    DateTime? date, {
    BuildContext? context,
    String fallback = '',
  }) {
    if (date == null) return fallback;
    final locale = _resolveLocale(context);
    return DateFormat('MMMM d, yyyy', locale).format(date.toLocal());
  }

  /// Formats date with time as 'MMM d, yyyy • h:mm a' (e.g. 'Sep 14, 2026 • 7:45 PM')
  static String formatDateTime(
    DateTime? date, {
    BuildContext? context,
    String fallback = '',
  }) {
    if (date == null) return fallback;
    final locale = _resolveLocale(context);
    final datePart = DateFormat.yMMMd(locale).format(date.toLocal());
    final timePart = DateFormat.jm(locale).format(date.toLocal());
    return '$datePart • $timePart';
  }

  /// Formats relative time (e.g. 'Just now', '39m ago', '2d ago', or 'Sep 14')
  static String formatRelativeTime(
    DateTime? dateTime, {
    BuildContext? context,
    String fallback = '',
  }) {
    if (dateTime == null) return fallback;
    final now = DateTime.now();
    final difference = now.difference(dateTime.toLocal());
    final l10n = context != null ? AppLocalizations.of(context) : null;

    if (difference.isNegative || difference.inSeconds < 45) {
      return l10n != null ? l10n.timeJustNow : 'Just now';
    } else if (difference.inMinutes < 60) {
      return l10n != null
          ? l10n.timeMinutesAgo(difference.inMinutes)
          : '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return l10n != null
          ? l10n.timeHoursAgo(difference.inHours)
          : '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return l10n != null
          ? l10n.timeDaysAgo(difference.inDays)
          : '${difference.inDays}d ago';
    } else {
      return formatShortDate(dateTime, context: context);
    }
  }
}
