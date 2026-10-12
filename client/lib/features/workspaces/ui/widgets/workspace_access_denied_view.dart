import 'package:client/core/theme/app_icon_size.dart';
import 'package:flutter/material.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class WorkspaceAccessDeniedView extends StatelessWidget {
  const WorkspaceAccessDeniedView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: AppSpacing.edgeInsetsAllXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: AppIconSize.display,
              color: AppColors.error,
            ),
            AppSpacing.gapHLg,
            Text(
              l10n.ownerOnlyAccess,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            AppSpacing.gapHXxl,
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.returnToWorkspace),
            ),
          ],
        ),
      ),
    );
  }
}
