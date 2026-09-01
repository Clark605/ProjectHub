import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:client/app.dart';
import 'package:client/core/constants/api_constants.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/storage/prefs_service.dart';
import 'package:client/core/utils/app_logger.dart';
import 'package:client/features/auth/cubit/app_auth_cubit.dart';
import 'package:client/features/auth/cubit/app_auth_state.dart';

void main() async {
  final startupTimer = AppLogger.startTimer(
    'App Startup to First Frame',
    tag: 'Startup',
  );
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve native splash until auth check completes
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize API constants (device / emulator detection)
  await ApiConstants.init();
  AppLogger.debug('Base URL configured: ${ApiConstants.baseUrl}', tag: 'Startup');

  // Initialize dependency injection
  await configureDependencies();

  final prefs = getIt<PrefsService>();
  final appAuthCubit = getIt<AppAuthCubit>();
  await appAuthCubit.checkAuthStatus();

  final isAuthenticated = appAuthCubit.state.maybeWhen(
    authenticated: (_) => true,
    orElse: () => false,
  );

  final String initialRoute;
  if (isAuthenticated) {
    initialRoute = RouteNames.workspaces;
  } else if (prefs.hasSeenOnboarding) {
    initialRoute = RouteNames.login;
  } else {
    initialRoute = RouteNames.onboarding;
  }

  // Remove native splash screen to show the initial route
  FlutterNativeSplash.remove();
  startupTimer.stop(note: 'initial route: $initialRoute');

  runApp(ProjectHubApp(initialRoute: initialRoute));

  // Silently validate session and refresh cached user in background
  if (isAuthenticated) {
    appAuthCubit.syncUser();
  }
}
