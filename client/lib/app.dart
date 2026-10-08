import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/cubit/app_settings_cubit.dart';
import 'package:client/core/cubit/app_settings_state.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/dialog/app_confirm_dialog.dart';
import 'package:client/core/network/auth_interceptor.dart';
import 'package:client/core/network/global_network_error_handler.dart';
import 'package:client/core/routes/app_navigator.dart';
import 'package:client/core/routes/app_router.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ProjectHubApp extends StatefulWidget {
  final String initialRoute;

  const ProjectHubApp({super.key, required this.initialRoute});

  @override
  State<ProjectHubApp> createState() => _ProjectHubAppState();
}

class _ProjectHubAppState extends State<ProjectHubApp> {
  StreamSubscription<String>? _networkErrorSubscription;
  StreamSubscription<void>? _sessionExpiredSubscription;
  bool _isSessionExpiredDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _networkErrorSubscription = GlobalNetworkErrorHandler.onNetworkError.listen(
      (message) {
        final navState = AppNavigator.navigatorKey.currentState;
        final context = AppNavigator.navigatorKey.currentContext;
        if (navState != null && context != null && context.mounted) {
          navState.push<void>(
            DialogRoute<void>(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                final l10n = AppLocalizations.of(dialogContext);
                return AppConfirmDialog(
                  title: l10n?.connectionUnavailable ?? 'Connection unavailable',
                  message: message.contains('Unable to connect to the server')
                      ? (l10n?.connectionErrorMessage ?? message)
                      : message,
                  confirmLabel: l10n?.ok ?? 'OK',
                  showCancelButton: false,
                );
              },
            ),
          );
        }
      },
    );

    _sessionExpiredSubscription = AuthInterceptor.onSessionExpired.listen((_) {
      if (_isSessionExpiredDialogShowing) return;

      final authCubit = getIt<AppAuthCubit>();
      final isAuthenticated = authCubit.state.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      if (!isAuthenticated) return;

      final navState = AppNavigator.navigatorKey.currentState;
      final context = AppNavigator.navigatorKey.currentContext;
      if (navState == null || context == null || !context.mounted) return;

      _isSessionExpiredDialogShowing = true;
      navState.push<void>(
        DialogRoute<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            final l10n = AppLocalizations.of(dialogContext);
            return AppConfirmDialog(
              title: l10n?.sessionExpiredTitle ?? 'Session Expired',
              message: l10n?.sessionExpiredMessage ??
                  'Your session has expired. Please log in again to continue.',
              confirmLabel: l10n?.reauthenticate ?? 'Log In',
              showCancelButton: false,
              onConfirm: () async {
                Navigator.of(dialogContext).pop();
                _isSessionExpiredDialogShowing = false;
                await authCubit.logout();
                navState.pushNamedAndRemoveUntil(
                  RouteNames.login,
                  (route) => false,
                );
              },
            );
          },
        ),
      ).then((_) {
        _isSessionExpiredDialogShowing = false;
      });
    });
  }

  @override
  void dispose() {
    _networkErrorSubscription?.cancel();
    _sessionExpiredSubscription?.cancel();
    super.dispose();
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
            theme: AppTheme.lightTheme(settingsState.locale),
            darkTheme: AppTheme.darkTheme(settingsState.locale),
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
