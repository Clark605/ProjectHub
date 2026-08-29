import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:client/app.dart';
import 'package:client/core/di/injection.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Preserve native splash until auth check completes
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize dependency injection
  await configureDependencies();

  runApp(const ProjectHubApp());
}
