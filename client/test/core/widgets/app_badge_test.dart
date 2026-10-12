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

    testWidgets(
      'uses AppColors.badgeBackground in light and dark themes for standard and emphasis states',
      (tester) async {
        // Light theme, standard
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: const Scaffold(
              body: AppBadge(label: 'High', color: AppColors.priorityHigh),
            ),
          ),
        );

        var container = tester.widget<Container>(find.byType(Container).first);
        var decoration = container.decoration as BoxDecoration;
        expect(
          decoration.color,
          AppColors.badgeBackground(AppColors.priorityHigh, false),
        );
        expect(
          decoration.color,
          AppColors.priorityHigh.withValues(alpha: 0.12),
        );

        // Dark theme, standard
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: const Scaffold(
              body: AppBadge(label: 'High', color: AppColors.priorityHigh),
            ),
          ),
        );
        await tester.pumpAndSettle();

        container = tester.widget<Container>(find.byType(Container).first);
        decoration = container.decoration as BoxDecoration;
        expect(
          decoration.color,
          AppColors.badgeBackground(AppColors.priorityHigh, true),
        );
        expect(decoration.color, AppColors.priorityHigh.withValues(alpha: 0.2));

        // Emphasis in light and dark themes
        for (final isDark in [false, true]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: isDark ? ThemeData.dark() : ThemeData.light(),
              home: const Scaffold(
                body: AppBadge(
                  label: 'Overdue',
                  color: AppColors.error,
                  isEmphasis: true,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          container = tester.widget<Container>(find.byType(Container).first);
          decoration = container.decoration as BoxDecoration;
          expect(
            decoration.color,
            AppColors.badgeBackground(AppColors.error, isDark, emphasis: true),
          );
          expect(decoration.color, AppColors.error.withValues(alpha: 0.15));
        }
      },
    );
  });
}
