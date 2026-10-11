import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/profile/ui/widgets/faq_section.dart';
import 'package:client/features/profile/ui/widgets/language_selector_tile.dart';
import 'package:client/features/profile/ui/widgets/logout_card.dart';
import 'package:client/features/profile/ui/widgets/profile_header_card.dart';
import 'package:client/features/profile/ui/widgets/theme_mode_selector.dart';
import 'package:client/features/profile/ui/widgets/version_info_tile.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocBuilder<AppAuthCubit, AppAuthState>(
      builder: (context, state) {
        final user = state.whenOrNull(authenticated: (u) => u);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.xl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profileAndSettings,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  AppSpacing.gapH4,
                  Text(
                    l10n.profileSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.65,
                      ),
                    ),
                  ),
                  AppSpacing.gapH24,
                  ProfileHeaderCard(user: user),
                  AppSpacing.gapH16,
                  const ThemeModeSelector(),
                  AppSpacing.gapH16,
                  const LanguageSelectorTile(),
                  AppSpacing.gapH16,
                  const FaqSection(),
                  AppSpacing.gapH16,
                  const VersionInfoTile(),
                  AppSpacing.gapH16,
                  const LogoutCard(),
                  AppSpacing.gapH24,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
