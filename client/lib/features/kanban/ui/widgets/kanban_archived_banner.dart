import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';
import 'package:client/l10n/generated/app_localizations.dart';

class KanbanArchivedBanner extends StatelessWidget {
  const KanbanArchivedBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.warning.withValues(alpha: 0.15),
      child: Row(
        children: [
          const Icon(Icons.archive_outlined, size: 18, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n?.archivedProjectNotice ??
                  'This project is archived. Tasks and board are read-only.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
