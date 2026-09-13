import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:client/core/widgets/ambient_glow_background.dart';
import 'package:client/core/widgets/ambient_glow_painter.dart';

void main() {
  group('AmbientGlowBackground', () {
    testWidgets('renders ColoredBox when showGlow is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AmbientGlowBackground(
              showGlow: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AmbientGlowBackground),
          matching: find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is AmbientGlowPainter,
          ),
        ),
        findsNothing,
      );
      expect(find.byType(ColoredBox), findsOneWidget);
    });

    testWidgets('renders CustomPaint with AmbientGlowPainter in light mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: AmbientGlowBackground(
              showGlow: true,
              child: Text('Light Mode Content'),
            ),
          ),
        ),
      );

      // Verify the child is rendered
      expect(find.text('Light Mode Content'), findsOneWidget);

      // Verify CustomPaint with AmbientGlowPainter is rendered in light mode
      final customPaintFinder = find.byType(CustomPaint);
      expect(customPaintFinder, findsWidgets);

      final customPaint = tester.widget<CustomPaint>(
        find
            .descendant(
              of: find.byType(AmbientGlowBackground),
              matching: customPaintFinder,
            )
            .first,
      );

      expect(customPaint.painter, isA<AmbientGlowPainter>());
      final painter = customPaint.painter as AmbientGlowPainter;
      expect(painter.opacity, 0.45 * 2);
    });

    testWidgets('renders CustomPaint with AmbientGlowPainter in dark mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: const Scaffold(
            body: AmbientGlowBackground(
              showGlow: true,
              child: Text('Dark Mode Content'),
            ),
          ),
        ),
      );

      // Verify the child is rendered
      expect(find.text('Dark Mode Content'), findsOneWidget);

      // Verify CustomPaint with AmbientGlowPainter is rendered in dark mode
      final customPaintFinder = find.byType(CustomPaint);
      expect(customPaintFinder, findsWidgets);

      final customPaint = tester.widget<CustomPaint>(
        find
            .descendant(
              of: find.byType(AmbientGlowBackground),
              matching: customPaintFinder,
            )
            .first,
      );

      expect(customPaint.painter, isA<AmbientGlowPainter>());
      final painter = customPaint.painter as AmbientGlowPainter;
      expect(painter.opacity, 0.45);
    });
  });
}
