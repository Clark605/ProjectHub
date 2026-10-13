import 'package:flutter/material.dart';

/// Standard wrapper for displaying modal dialogs across the application.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: builder,
  );
}

/// Pushes a [DialogRoute] using the navigator for custom transitions or modal routing.
Future<T?> pushAppDialogRoute<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  RouteSettings? routeSettings,
}) {
  return Navigator.of(context).push<T>(
    DialogRoute<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
      settings: routeSettings,
    ),
  );
}
