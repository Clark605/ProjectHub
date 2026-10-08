import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client/core/cubit/app_settings_cubit.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/l10n/generated/app_localizations.dart';

/// Helper to wrap widgets with standard MaterialApp, localization delegates,
/// theme, and mock BlocProviders for testing without production test seams.
Widget pumpApp({
  required Widget child,
  AppAuthCubit? authCubit,
  WorkspaceContextCubit? workspaceCubit,
  AppSettingsCubit? settingsCubit,
  List<BlocProvider> providers = const [],
  Map<String, WidgetBuilder>? routes,
  ThemeData? theme,
  NavigatorObserver? navigatorObserver,
}) {
  final effectiveProviders = <BlocProvider>[
    if (authCubit != null) BlocProvider<AppAuthCubit>.value(value: authCubit),
    if (workspaceCubit != null)
      BlocProvider<WorkspaceContextCubit>.value(value: workspaceCubit),
    if (settingsCubit != null)
      BlocProvider<AppSettingsCubit>.value(value: settingsCubit),
    ...providers,
  ];

  Widget app = MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: theme ?? AppTheme.lightTheme(),
    routes: routes ?? const <String, WidgetBuilder>{},
    navigatorObservers: [?navigatorObserver],
    home: child,
  );

  if (effectiveProviders.isNotEmpty) {
    app = MultiBlocProvider(providers: effectiveProviders, child: app);
  }

  return app;
}
