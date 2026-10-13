import 'dart:async';

import 'package:client/core/cubit/app_settings_cubit.dart';
import 'package:client/core/cubit/app_settings_state.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/dialog/app_confirm_dialog.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/network/auth_interceptor.dart';
import 'package:client/core/network/global_network_error_handler.dart';
import 'package:client/core/routes/app_navigator.dart';
import 'package:client/core/routes/app_router.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';
import 'package:client/features/workspaces/cubit/workspace_context_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectHubApp extends StatefulWidget {
  final String initialRoute;

  const ProjectHubApp({super.key, required this.initialRoute});

  @override
  State<ProjectHubApp> createState() => _ProjectHubAppState();
}

class _ProjectHubAppState extends State<ProjectHubApp> {
  StreamSubscription<AppFailure>? _networkErrorSubscription;
  StreamSubscription<void>? _sessionExpiredSubscription;
  bool _isSessionExpiredDialogShowing = false;

  @override
  void initState() {
    super.initState();
    final authCubit = getIt<AppAuthCubit>();
    if (authCubit.state.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    )) {
      getIt<WorkspaceContextCubit>().loadWorkspaces();
    }

    _networkErrorSubscription = GlobalNetworkErrorHandler.onNetworkError.listen(
      (failure) {
        final context = AppNavigator.navigatorKey.currentContext;
        if (context != null && context.mounted) {
          showAppConfirmDialog(
            context: context,
            barrierDismissible: false,
            title: context.l10n.connectionUnavailable,
            message: failure.localized(context),
            confirmLabel: context.l10n.ok,
            showCancelButton: false,
          );
        }
      },
    );

    _sessionExpiredSubscription = AuthInterceptor.onSessionExpired.listen((_) {
      if (_isSessionExpiredDialogShowing) return;

      final currentAuthCubit = getIt<AppAuthCubit>();
      final isAuthenticated = currentAuthCubit.state.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      if (!isAuthenticated) return;

      final context = AppNavigator.navigatorKey.currentContext;
      if (context == null || !context.mounted) return;

      _isSessionExpiredDialogShowing = true;
      final l10n = context.l10n;
      showAppConfirmDialog(
        context: context,
        barrierDismissible: false,
        title: l10n.sessionExpiredTitle,
        message: l10n.sessionExpiredMessage,
        confirmLabel: l10n.reauthenticate,
        showCancelButton: false,
        onConfirm: () async {
          Navigator.of(context).pop();
          _isSessionExpiredDialogShowing = false;
          await currentAuthCubit.logout();
          unawaited(
            AppNavigator.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              RouteNames.login,
              (route) => false,
            ),
          );
        },
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
      child: BlocListener<AppAuthCubit, AppAuthState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, authState) {
          authState.maybeWhen(
            authenticated: (_) {
              context.read<WorkspaceContextCubit>().loadWorkspaces();
            },
            unauthenticated: () {
              context.read<WorkspaceContextCubit>().reset();
            },
            orElse: () {},
          );
        },
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
      ),
    );
  }
}
