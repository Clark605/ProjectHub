import 'package:flutter/material.dart';
import 'package:client/l10n/generated/app_localizations.dart';

import 'package:client/core/routes/app_router.dart';
import 'package:client/core/routes/app_navigator.dart';
import 'package:client/core/theme/app_theme.dart';
import 'package:client/core/network/global_network_error_handler.dart';

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
          builder: (context) => AlertDialog(
            title: const Text('Connection unavailable'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProjectHub',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppNavigator.navigatorKey,

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,

      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // Routing
      initialRoute: widget.initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
