import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    final fixedDate = DateTime(2026, 10, 14, 15, 30);

    test('formatDate formats correctly and respects fallback', () {
      expect(DateFormatter.formatDate(null, fallback: 'N/A'), 'N/A');
      final formatted = DateFormatter.formatDate(fixedDate);
      expect(formatted, contains('2026'));
      expect(formatted, contains('14'));
    });

    test('formatShortDate formats correctly and respects fallback', () {
      expect(DateFormatter.formatShortDate(null, fallback: '--'), '--');
      final formatted = DateFormatter.formatShortDate(fixedDate);
      expect(formatted, contains('14'));
    });

    test('formatFullDate formats correctly and respects fallback', () {
      expect(DateFormatter.formatFullDate(null, fallback: 'None'), 'None');
      final formatted = DateFormatter.formatFullDate(fixedDate);
      expect(formatted, contains('October'));
      expect(formatted, contains('14'));
      expect(formatted, contains('2026'));
    });

    test('formatDateTime formats date and time parts', () {
      expect(DateFormatter.formatDateTime(null, fallback: 'None'), 'None');
      final formatted = DateFormatter.formatDateTime(fixedDate);
      expect(formatted, contains('•'));
    });

    test('formatRelativeTime formats past intervals correctly', () {
      expect(DateFormatter.formatRelativeTime(null, fallback: '-'), '-');

      final now = DateTime.now();
      expect(
        DateFormatter.formatRelativeTime(
          now.subtract(const Duration(seconds: 10)),
        ),
        'Just now',
      );

      expect(
        DateFormatter.formatRelativeTime(
          now.subtract(const Duration(minutes: 5)),
        ),
        '5m ago',
      );

      expect(
        DateFormatter.formatRelativeTime(
          now.subtract(const Duration(hours: 3)),
        ),
        '3h ago',
      );

      expect(
        DateFormatter.formatRelativeTime(now.subtract(const Duration(days: 4))),
        '4d ago',
      );

      final older = now.subtract(const Duration(days: 30));
      expect(
        DateFormatter.formatRelativeTime(older),
        DateFormatter.formatShortDate(older),
      );
    });
  });
}
