import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/cubit/app_settings_cubit.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/auth/data/auth_repository.dart';
import 'package:client/features/profile/cubit/profile_edit_cubit.dart';
import 'package:client/features/profile/ui/widgets/faq_section.dart';
import 'package:client/features/profile/ui/widgets/language_selector_tile.dart';
import 'package:client/features/profile/ui/widgets/logout_card.dart';
import 'package:client/features/profile/ui/widgets/palette_carousel.dart';
import 'package:client/features/profile/ui/widgets/profile_header_card.dart';
import 'package:client/features/profile/ui/widgets/theme_mode_selector.dart';
import 'package:client/features/profile/ui/widgets/version_info_tile.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class _FallbackAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AppAuthCubit>()),
        if (getIt.isRegistered<AppSettingsCubit>())
          BlocProvider.value(value: getIt<AppSettingsCubit>())
        else if (getIt.isRegistered<PrefsService>())
          BlocProvider(create: (_) => AppSettingsCubit(getIt<PrefsService>())),
        BlocProvider(
          create: (_) => getIt.isRegistered<ProfileEditCubit>()
              ? getIt<ProfileEditCubit>()
              : ProfileEditCubit(
                  getIt.isRegistered<AuthRepository>()
                      ? getIt<AuthRepository>()
                      : _FallbackAuthRepository(),
                  getIt<AppAuthCubit>(),
                ),
        ),
      ],
      child: BlocBuilder<AppAuthCubit, AppAuthState>(
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
                    const PaletteCarousel(),
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
      ),
    );
  }
}
