import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/profile/ui/widgets/version_info_tile.dart';

void main() {
  testWidgets('VersionInfoTile renders author attribution text', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: VersionInfoTile())),
    );

    // Initial pump for FutureBuilder
    await tester.pump();

    expect(find.byType(VersionInfoTile), findsOneWidget);
    expect(find.textContaining('Made with ❤️ by Clark Remon'), findsOneWidget);
  });
}
