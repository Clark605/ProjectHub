import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/kanban/ui/widgets/voice/voice_task_fab.dart';

void main() {
  group('VoiceTaskFab', () {
    testWidgets('renders mic icon when idle and triggers callback on tap', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceTaskFab(
              isArchived: false,
              isListening: false,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
      expect(find.byIcon(Icons.stop_rounded), findsNothing);

      await tester.tap(find.byType(VoiceTaskFab));
      expect(tapped, isTrue);
    });

    testWidgets('renders stop icon when listening', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceTaskFab(
              isArchived: false,
              isListening: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsNothing);
    });

    testWidgets('renders nothing when archived', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VoiceTaskFab(
              isArchived: true,
              isListening: false,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.mic_rounded), findsNothing);
      expect(find.byIcon(Icons.stop_rounded), findsNothing);
    });
  });
}
