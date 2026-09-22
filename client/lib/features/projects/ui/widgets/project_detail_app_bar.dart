import 'package:flutter/material.dart';

import 'package:client/core/theme/workspace_accent.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class ProjectDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? wsAccent;

  const ProjectDetailAppBar({super.key, this.wsAccent});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final accentColor = wsAccent != null && wsAccent!.trim().isNotEmpty
        ? WorkspaceAccent.fromId(wsAccent!).resolvedColor(theme.brightness)
        : null;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      bottom: accentColor != null
          ? PreferredSize(
              preferredSize: const Size.fromHeight(2),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentColor,
                      accentColor.withValues(alpha: 0.6),
                      accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            )
          : null,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(
        l10n?.projectDetails ?? 'Project Details',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
