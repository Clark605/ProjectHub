import 'package:flutter/material.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/widgets/app_button.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class LogoutCard extends StatelessWidget {
  const LogoutCard({super.key});

  void _onLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(l10n?.logOut ?? 'Log Out'),
        content: Text(
          l10n?.logoutConfirmation ??
              'Are you sure you want to log out of your session on this device?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(true),
            child: Text(
              l10n?.logOut ?? 'Log Out',
              style: const TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final cubit = getIt<AppAuthCubit>();
      await cubit.logout();

      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.sessionSecurity ?? 'Session Security',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n?.sessionSecurityDesc ??
                        'Log out of your account on this device.',
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
                label: l10n?.logOut ?? 'Log Out',
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
