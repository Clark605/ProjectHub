import 'package:flutter/material.dart';
import 'package:client/core/dialog/app_bottom_sheet.dart';
import 'package:client/core/dialog/app_confirm_dialog.dart';

export 'package:client/core/dialog/dialog.dart';

/// Unified class for application dialogues and bottom sheets.
class AppDialogue {
  const AppDialogue._();

  /// Shows a standardized application bottom sheet.
  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double maxHeightFraction = 0.88,
  }) =>
      showAppBottomSheet<T>(
        context: context,
        builder: builder,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        backgroundColor: backgroundColor,
        maxHeightFraction: maxHeightFraction,
      );

  /// Shows a standardized confirmation dialog.
  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
  }) =>
      showAppConfirmDialog(
        context: context,
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      );
}

