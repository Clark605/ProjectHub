import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/cubit/app_settings_cubit.dart';
import 'package:client/core/cubit/app_settings_state.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class LanguageSelectorTile extends StatelessWidget {
  const LanguageSelectorTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, state) {
        final currentCode = state.locale.languageCode;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                    const SizedBox(width: 10),
                    Text(
                      l10n?.language ?? 'Language',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n?.languageSubtitle ??
                      'Switch the application language and reading layout (LTR / RTL).',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 16),
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
