import 'package:client/core/theme/app_icon_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/cubit/app_settings_cubit.dart';
import 'package:client/core/cubit/app_settings_state.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: AppSpacing.edgeInsetsAllXl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.palette_outlined,
                      size: AppIconSize.lg,
                      color: theme.colorScheme.primary,
                    ),
                    AppSpacing.gapWSm,
                    Text(
                      l10n.appearance,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapHXs,
                Text(
                  l10n.appearanceSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                AppSpacing.gapHLg,
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text(l10n.themeModeSystem),
                      icon: const Icon(Icons.brightness_auto_rounded),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text(l10n.themeModeDark),
                      icon: const Icon(Icons.dark_mode_rounded),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text(l10n.themeModeLight),
                      icon: const Icon(Icons.light_mode_rounded),
                    ),
                  ],
                  selected: {state.themeMode},
                  onSelectionChanged: (newSelection) {
                    if (newSelection.isNotEmpty) {
                      context.read<AppSettingsCubit>().setThemeMode(
                        newSelection.first,
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
