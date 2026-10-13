import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/profile/ui/widgets/faq_section.dart';
import 'package:client/features/profile/ui/widgets/language_selector_tile.dart';
import 'package:client/features/profile/ui/widgets/logout_card.dart';
import 'package:client/features/profile/ui/widgets/profile_header_card.dart';
import 'package:client/features/profile/ui/widgets/theme_mode_selector.dart';
import 'package:client/features/profile/ui/widgets/version_info_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                  AppSpacing.gapHXs,
                  Text(
                    l10n.profileSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.65,
                      ),
                    ),
                  ),
                  AppSpacing.gapHXxl,
                  ProfileHeaderCard(user: user),
                  AppSpacing.gapHLg,
                  const ThemeModeSelector(),
                  AppSpacing.gapHLg,
                  const LanguageSelectorTile(),
                  AppSpacing.gapHLg,
                  const FaqSection(),
                  AppSpacing.gapHLg,
                  const VersionInfoTile(),
                  AppSpacing.gapHLg,
                  const LogoutCard(),
                  AppSpacing.gapHXxl,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
