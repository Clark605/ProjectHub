import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/theme/app_avatar_size.dart';
import 'package:client/core/theme/app_icon_size.dart';
import 'package:client/core/widgets/app_avatar.dart';

void main() {
  group('AppAvatar', () {
    testWidgets('renders single letter initials for single-word name', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppAvatar(name: 'Clark')),
        ),
      );

      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('renders two letters initials for two-word name', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppAvatar(name: 'Clark Kent')),
        ),
      );

      expect(find.text('CK'), findsOneWidget);
    });

    testWidgets('handles whitespace-only name by rendering question mark', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppAvatar(name: '   ')),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('handles empty name by rendering question mark', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppAvatar(name: '')),
        ),
      );

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('produces identical background colors for same name', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppAvatar(key: Key('avatar1'), name: 'Alice Bob'),
                AppAvatar(key: Key('avatar2'), name: 'Alice Bob'),
              ],
            ),
          ),
        ),
      );

      final container1 = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const Key('avatar1')),
          matching: find.byType(Container),
        ),
      );
      final container2 = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const Key('avatar2')),
          matching: find.byType(Container),
        ),
      );

      final deco1 = container1.decoration as BoxDecoration;
      final deco2 = container2.decoration as BoxDecoration;

      expect(deco1.color, equals(deco2.color));
    });

    testWidgets(
      'caller textStyle with only fontWeight keeps computed size and color',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  AppAvatar(
                    key: Key('defaultAvatar'),
                    name: 'Diana Prince',
                    size: 28,
                  ),
                  AppAvatar(
                    key: Key('customWeightAvatar'),
                    name: 'Diana Prince',
                    size: 28,
                    textStyle: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        );

        final defaultText = tester.widget<Text>(
          find.descendant(
            of: find.byKey(const Key('defaultAvatar')),
            matching: find.byType(Text),
          ),
        );
        final customText = tester.widget<Text>(
          find.descendant(
            of: find.byKey(const Key('customWeightAvatar')),
            matching: find.byType(Text),
          ),
        );

        expect(customText.style?.fontWeight, FontWeight.w600);
        expect(customText.style?.fontSize, equals(28 * 0.4));
        expect(customText.style?.fontSize, equals(defaultText.style?.fontSize));
        expect(customText.style?.color, isNotNull);
        expect(customText.style?.color, equals(defaultText.style?.color));
      },
    );

    testWidgets('AppAvatar.unassigned renders person icon and obeys size', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppAvatar.unassigned(key: Key('defaultUnassigned')),
                AppAvatar.unassigned(
                  key: Key('largeUnassigned'),
                  size: AppAvatarSize.lg,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person_outline_rounded), findsNWidgets(2));

      final defaultContainer = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const Key('defaultUnassigned')),
          matching: find.byType(Container),
        ),
      );
      expect(defaultContainer.constraints?.maxWidth, AppAvatarSize.sm);
      expect(defaultContainer.constraints?.maxHeight, AppAvatarSize.sm);

      final largeContainer = tester.widget<Container>(
        find.descendant(
          of: find.byKey(const Key('largeUnassigned')),
          matching: find.byType(Container),
        ),
      );
      expect(largeContainer.constraints?.maxWidth, AppAvatarSize.lg);
      expect(largeContainer.constraints?.maxHeight, AppAvatarSize.lg);

      final largeIcon = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const Key('largeUnassigned')),
          matching: find.byType(Icon),
        ),
      );
      expect(largeIcon.size, AppIconSize.lg);
    });
  });
}
