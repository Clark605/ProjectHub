import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/dialog/app_confirm_dialog.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class LogoutCard extends StatelessWidget {
  const LogoutCard({super.key});

  void _onLogout(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: l10n.logOut,
      message: l10n.logoutConfirmation,
      confirmLabel: l10n.logOut,
      cancelLabel: l10n.cancel,
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      final cubit = context.read<AppAuthCubit>();
      await cubit.logout();

      if (!context.mounted) return;
      unawaited(
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.login,
          (route) => false,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: AppSpacing.edgeInsetsAllXl,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.sessionSecurity,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.gapHXxs,
                  Text(
                    l10n.sessionSecurityDesc,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AppButton(
                label: l10n.logOut,
                icon: Icons.logout_rounded,
                variant: AppButtonVariant.outline,
                onPressed: () => _onLogout(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
