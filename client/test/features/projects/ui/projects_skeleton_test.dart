import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/projects/ui/widgets/projects_skeleton.dart';

void main() {
  testWidgets(
    'ProjectsSkeleton renders on mobile viewport without RenderFlex overflow',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ProjectsSkeleton())),
      );

      final exception = tester.takeException();
      expect(
        exception,
        isNull,
        reason: 'ProjectsSkeleton should not overflow on mobile viewport',
      );
    },
  );
}
