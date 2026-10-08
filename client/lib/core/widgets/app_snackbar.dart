import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/theme/app_radius.dart';

/// Standardized SnackBar functions across the application.
void showAppSnackBar(
  BuildContext context,
  String message, {
  Color backgroundColor = AppColors.surface,
  Color textColor = Colors.white,
  SnackBarAction? action,
}) {
  context._showSnackBar(
    message,
    backgroundColor,
    textColor: textColor,
    action: action,
  );
}

void showAppSuccessSnackBar(BuildContext context, String message) {
  context.showSuccessSnackBar(message);
}

void showAppErrorSnackBar(BuildContext context, String message) {
  context.showErrorSnackBar(message);
}

void showAppInfoSnackBar(BuildContext context, String message) {
  context.showInfoSnackBar(message);
}

extension AppSnackBarExtension on BuildContext {
  void showSuccessSnackBar(String message) {
    _showSnackBar(message, AppColors.success);
  }

  void showErrorSnackBar(String message) {
    _showSnackBar(message, AppColors.error, textColor: AppColors.onError);
  }

  void showInfoSnackBar(String message) {
    _showSnackBar(message, AppColors.info, textColor: AppColors.onSkyBlue);
  }

  void _showSnackBar(
    String message,
    Color backgroundColor, {
    Color textColor = Colors.white,
    SnackBarAction? action,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(this);
    if (scaffoldMessenger == null) return;

    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.kRadiusSm),
        action: action,
      ),
    );
  }
}
