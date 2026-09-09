import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/cubit/app_settings_cubit.dart';
import 'package:client/core/cubit/app_settings_state.dart';
import 'package:client/core/theme/app_palette.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class PaletteCarousel extends StatelessWidget {
  const PaletteCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.color_lens_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      l10n?.colorPalette ?? 'Color Palette',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  l10n?.colorPaletteSubtitle ??
                      'Select a curated palette to dynamically re-theme buttons, surfaces, and ambient glow.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppPalette.values.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final palette = AppPalette.values[index];
                      final isSelected = palette.id == state.palette.id;
                      final tokens = palette.tokens(isDark ? Brightness.dark : Brightness.light);

                      return InkWell(
                        onTap: () => context.read<AppSettingsCubit>().setPalette(palette),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 155,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tokens.canvasBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? tokens.primary
                                  : tokens.border.withValues(alpha: 0.6),
                              width: isSelected ? 2.2 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: tokens.primary.withValues(alpha: 0.25),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: tokens.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 18,
                                        height: 18,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: tokens.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 18,
                                      color: tokens.primary,
                                    ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    palette.name,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: tokens.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    palette.description,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: tokens.textSecondary,
                                      fontSize: 10,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
