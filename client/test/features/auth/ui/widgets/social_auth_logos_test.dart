import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client/features/auth/ui/widgets/google_logo.dart';
import 'package:client/features/auth/ui/widgets/github_logo.dart';

void main() {
  group('Social Auth Logos', () {
    testWidgets('GoogleLogo renders SvgPicture with default size', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: GoogleLogo())),
      );

      final svgFinder = find.byType(SvgPicture);
      expect(svgFinder, findsOneWidget);
      final googleLogoFinder = find.byType(GoogleLogo);
      expect(googleLogoFinder, findsOneWidget);
    });

    testWidgets('GithubLogo renders SvgPicture with custom color and size', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GithubLogo(size: 24, color: Colors.white)),
        ),
      );

      final svgFinder = find.byType(SvgPicture);
      expect(svgFinder, findsOneWidget);
      final githubLogoFinder = find.byType(GithubLogo);
      expect(githubLogoFinder, findsOneWidget);
    });
  });
}
