import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';

/// Shows a standardized bottom sheet with unified styling, 20px top radius,
/// drag handle, responsive maximum width, and keyboard viewInsets handling.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  Color? backgroundColor,
  double? maxHeightFraction,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final screenHeight = MediaQuery.sizeOf(context).height;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor:
        backgroundColor ??
        (isDark ? AppColors.surface : AppColors.lightSurface),
    elevation: 0,
    barrierColor: Colors.black54,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      side: BorderSide(
        color: isDark ? AppColors.borderVariant : AppColors.lightBorder,
        width: 1,
      ),
    ),
    constraints: BoxConstraints(
      maxWidth: 580,
      maxHeight: screenHeight * (maxHeightFraction ?? 0.88),
    ),
    builder: (ctx) {
      final viewInsets = MediaQuery.viewInsetsOf(ctx);

      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: builder(ctx),
        ),
      );
    },
  );
}

/// Standardized drag handle for bottom sheets.
class AppSheetDragHandle extends StatelessWidget {
  const AppSheetDragHandle({
    super.key,
    this.width = 36,
    this.height = 4,
    this.margin = const EdgeInsets.only(top: 10, bottom: 8),
  });

  final double width;
  final double height;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        margin: margin,
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.borderVariant : AppColors.lightBorder,
          borderRadius: BorderRadius.all(Radius.circular(height / 2)),
        ),
      ),
    );
  }
}

/// Standardized header for bottom sheets containing title, optional subtitle, and close button.
class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showCloseButton = true,
    this.onClose,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 12),
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showCloseButton;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppColors.textSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ?trailing,
          if (showCloseButton)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
        ],
      ),
    );
  }
}
