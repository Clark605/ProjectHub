import 'package:flutter/material.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import 'package:client/core/routes/app_router.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:client/core/network/global_network_error_handler.dart';

class ProjectHubApp extends StatelessWidget {
  final String initialRoute;

  const ProjectHubApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProjectHub',
      debugShowCheckedModeBanner: false,
      navigatorKey: GlobalNetworkErrorHandler.navigatorKey,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,

      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Routing
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
