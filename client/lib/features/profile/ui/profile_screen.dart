import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/profile/cubit/profile_edit_cubit.dart';
import 'package:client/features/profile/ui/widgets/faq_section.dart';
import 'package:client/features/profile/ui/widgets/language_selector_tile.dart';
import 'package:client/features/profile/ui/widgets/logout_card.dart';
import 'package:client/features/profile/ui/widgets/profile_header_card.dart';
import 'package:client/features/profile/ui/widgets/theme_mode_selector.dart';
import 'package:client/features/profile/ui/widgets/version_info_tile.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  final ProfileEditCubit? cubit;

  const ProfileScreen({super.key, this.cubit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final content = BlocBuilder<AppAuthCubit, AppAuthState>(
      builder: (context, state) {
        final user = state.whenOrNull(authenticated: (u) => u);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.profileAndSettings ?? 'Profile & Settings',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n?.profileSubtitle ??
                          'Manage credentials, appearance, dynamic themes, language, and support.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ProfileHeaderCard(user: user),
                    const SizedBox(height: 16),
                    const ThemeModeSelector(),
                    const SizedBox(height: 16),
                    const LanguageSelectorTile(),
                    const SizedBox(height: 16),
                    const FaqSection(),
                    const SizedBox(height: 16),
                    const VersionInfoTile(),
                    const SizedBox(height: 16),
                    const LogoutCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      );

    Widget effectiveContent = content;

    if (cubit != null) {
      effectiveContent = BlocProvider.value(value: cubit!, child: effectiveContent);
    } else {
      try {
        context.read<ProfileEditCubit>();
      } catch (_) {
        if (getIt.isRegistered<ProfileEditCubit>()) {
          effectiveContent = BlocProvider(
            create: (_) => getIt<ProfileEditCubit>(),
            child: effectiveContent,
          );
        }
      }
    }

    try {
      context.read<AppAuthCubit>();
    } catch (_) {
      if (getIt.isRegistered<AppAuthCubit>()) {
        effectiveContent = BlocProvider.value(
          value: getIt<AppAuthCubit>(),
          child: effectiveContent,
        );
      }
    }

    return effectiveContent;
  }
}
