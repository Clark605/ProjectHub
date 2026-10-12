import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/widgets/app_badge.dart';

void main() {
  group('AppBadge', () {
    testWidgets('renders label and optional icon with given color', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppBadge(
              icon: Icons.flag_rounded,
              label: 'Urgent',
              color: AppColors.priorityUrgent,
            ),
          ),
        ),
      );

      expect(find.text('Urgent'), findsOneWidget);
      final icon = tester.widget<Icon>(find.byIcon(Icons.flag_rounded));
      expect(icon.color, AppColors.priorityUrgent);
      expect(icon.size, AppIconSize.xxs);

      final text = tester.widget<Text>(find.text('Urgent'));
      expect(text.style?.color, AppColors.priorityUrgent);
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('renders without icon and applies emphasis weight when set', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppBadge(
              label: 'Overdue',
              color: AppColors.error,
              isEmphasis: true,
            ),
          ),
        ),
      );

      expect(find.byType(Icon), findsNothing);
      final text = tester.widget<Text>(find.text('Overdue'));
      expect(text.style?.color, AppColors.error);
      expect(text.style?.fontWeight, FontWeight.w700);
    });
  });
}

