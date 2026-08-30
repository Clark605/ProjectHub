import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class AuthBackToLoginLink extends StatelessWidget {
  const AuthBackToLoginLink({super.key, this.delayMs = 400});

  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.arrow_back_rounded,
          size: 16,
          color: isDark
              ? AppColors.textSecondary
              : AppColors.lightTextSecondary,
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.login,
              (route) => false,
            );
          },
          child: Text(
            l10n.backToSignIn,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textPrimary
                  : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(
      duration: 400.ms,
      delay: Duration(milliseconds: delayMs),
    );
  }
}
