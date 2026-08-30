import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:client/app.dart';
import 'package:client/core/di/injection.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/storage/prefs_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve native splash until auth check completes
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize dependency injection
  await configureDependencies();

  final prefs = getIt<PrefsService>();
  final initialRoute = prefs.hasSeenOnboarding
      ? RouteNames.login
      : RouteNames.onboarding;

  // Remove native splash screen to show the initial route
  FlutterNativeSplash.remove();

  runApp(ProjectHubApp(initialRoute: initialRoute));
}
