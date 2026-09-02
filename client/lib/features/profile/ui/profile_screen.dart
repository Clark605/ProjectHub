import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/profile/ui/widgets/profile_identity_card.dart';
import 'package:client/features/profile/ui/widgets/session_security_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _onLogout(BuildContext context) async {
    final cubit = getIt<AppAuthCubit>();
    await cubit.logout();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: getIt<AppAuthCubit>(),
      child: BlocBuilder<AppAuthCubit, AppAuthState>(
        builder: (context, state) {
          final user = state.whenOrNull(authenticated: (u) => u);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Profile & Settings',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your account credentials, security sessions, and preferences.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Profile Identity Card ──
                ProfileIdentityCard(user: user),
                const SizedBox(height: 24),

                // ── Session & Security Details ──
                const SessionSecurityCard(),
                const SizedBox(height: 32),

                // ── Logout Action ──
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: AppButton(
                    label: 'Log Out',
                    icon: Icons.logout_rounded,
                    variant: AppButtonVariant.outline,
                    onPressed: () => _onLogout(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
