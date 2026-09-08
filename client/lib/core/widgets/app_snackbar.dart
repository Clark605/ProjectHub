import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';

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
  }) {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(this);
    if (scaffoldMessenger == null) return;

    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
