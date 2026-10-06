import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:client/core/theme/dark_theme.dart';
import 'package:client/features/kanban/ui/widgets/voice/voice_listening_overlay.dart';
import 'package:client/features/tasks/cubit/voice_task_cubit.dart';
import 'package:client/features/tasks/data/models/parsed_task_draft_dto.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import '../../../../helpers/mock_repositories.dart';

void main() {
  testWidgets('VoiceListeningOverlay renders cleanly under DarkTheme with no infinite width error', (tester) async {
    final mockAiRepo = MockAiTaskRepository();
    when(
      () => mockAiRepo.parseTaskFromText(
        text: any(named: 'text'),
        projectId: any(named: 'projectId'),
        workspaceId: any(named: 'workspaceId'),
      ),
    ).thenAnswer((_) async => const ParsedTaskDraftDto(title: 'Title'));

    final cubit = VoiceTaskCubit(mockAiRepo);

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
    expect(find.byType(VoiceListeningOverlay), findsOneWidget);

    await cubit.close();
  });
}
