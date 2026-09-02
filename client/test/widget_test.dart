import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:client/app.dart';
import 'package:client/core/di/injection.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('ProjectHubApp renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProjectHubApp(initialRoute: '/onboarding'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(ProjectHubApp), findsOneWidget);
  });
}
