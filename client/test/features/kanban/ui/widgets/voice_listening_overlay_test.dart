import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/theme/dark_theme.dart';
import 'package:client/features/kanban/ui/widgets/voice_listening_overlay.dart';
import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/tasks/data/ai_task_repository.dart';
import 'package:client/features/tasks/data/models/parsed_task_draft_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class _FakeAiRepo implements AiTaskRepository {
  @override
  Future<ParsedTaskDraftDto> parseTaskFromText({
    required String text,
    required int projectId,
    required int workspaceId,
  }) async =>
      const ParsedTaskDraftDto(title: 'Title');
}

void main() {
  testWidgets('VoiceListeningOverlay renders cleanly under DarkTheme with no infinite width error', (tester) async {
    final cubit = VoiceTaskCubit(_FakeAiRepo());

    await tester.pumpWidget(
      MaterialApp(
        theme: buildDarkTheme(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider.value(
            value: cubit,
            child: VoiceListeningOverlay(
              onCancel: () {},
              onDone: () {},
              animate: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Done Speaking'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await cubit.close();
  });
}
