import 'package:client/core/di/injection.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import 'package:client/core/routes/app_router.dart';
import 'package:client/core/routes/app_navigator.dart';
import 'package:client/core/network/global_network_error_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/theme/app_theme.dart';
import 'package:client/core/cubit/app_settings_cubit.dart';
import 'package:client/core/cubit/app_settings_state.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';

class ProjectHubApp extends StatefulWidget {
  final String initialRoute;

  const ProjectHubApp({super.key, required this.initialRoute});

  @override
  State<ProjectHubApp> createState() => _ProjectHubAppState();
}

class _ProjectHubAppState extends State<ProjectHubApp> {
  @override
  void initState() {
    super.initState();
    GlobalNetworkErrorHandler.onNetworkError.listen((message) {
      final context = AppNavigator.navigatorKey.currentState?.overlay?.context;
      if (context != null && context.mounted) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            final l10n = AppLocalizations.of(dialogContext);
            return AlertDialog(
              title: Text(
                l10n?.connectionUnavailable ?? 'Connection unavailable',
              ),
              content: Text(
                message.contains('Unable to connect to the server')
                    ? (l10n?.connectionErrorMessage ?? message)
                    : message,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n?.ok ?? 'OK'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppAuthCubit>.value(value: getIt<AppAuthCubit>()),
        BlocProvider<WorkspaceContextCubit>.value(
          value: getIt<WorkspaceContextCubit>(),
        ),
        BlocProvider<AppSettingsCubit>.value(value: getIt<AppSettingsCubit>()),
      ],
      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settingsState) {
          return MaterialApp(
            title: 'ProjectHub',
            debugShowCheckedModeBanner: false,
            navigatorKey: AppNavigator.navigatorKey,

            // Brand Theme (Deep Slate) & Mode
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: settingsState.themeMode,

            // Localization
            locale: settingsState.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,

            // Routing
            initialRoute: widget.initialRoute,
            onGenerateInitialRoutes: (initialRoute) => [
              AppRouter.onGenerateRoute(RouteSettings(name: initialRoute))!,
            ],
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
