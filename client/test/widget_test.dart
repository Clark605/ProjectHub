import 'package:flutter_test/flutter_test.dart';

import 'package:client/app.dart';

void main() {
  testWidgets('ProjectHubApp renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProjectHubApp(initialRoute: '/onboarding'));
    await tester.pump(const Duration(milliseconds: 500));
    // App should build without errors
    expect(find.byType(ProjectHubApp), findsOneWidget);
  });
}
