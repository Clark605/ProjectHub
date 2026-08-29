import 'package:flutter/material.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import 'package:client/core/routes/app_router.dart';
import 'package:client/core/routes/route_names.dart';
import 'package:client/core/theme/app_theme.dart';

class ProjectHubApp extends StatelessWidget {
  const ProjectHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProjectHub',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,

      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Routing
      initialRoute: RouteNames.login,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
