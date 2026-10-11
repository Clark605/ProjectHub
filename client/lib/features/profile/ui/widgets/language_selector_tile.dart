import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/cubit/app_settings_cubit.dart';
import 'package:client/core/cubit/app_settings_state.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class LanguageSelectorTile extends StatelessWidget {
  const LanguageSelectorTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, state) {
        final currentCode = state.locale.languageCode;

        return Card(
          child: Padding(
            padding: AppSpacing.edgeInsetsAll20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.language_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    AppSpacing.gapW10,
                    Text(
                      l10n.language,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapH6,
                Text(
                  l10n.languageSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                AppSpacing.gapH16,
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(value: 'en', label: Text('English')),
                    ButtonSegment<String>(value: 'ar', label: Text('العربية')),
                  ],
                  selected: {currentCode},
                  onSelectionChanged: (newSelection) {
                    if (newSelection.isNotEmpty) {
                      context.read<AppSettingsCubit>().setLocale(
                        Locale(newSelection.first),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
