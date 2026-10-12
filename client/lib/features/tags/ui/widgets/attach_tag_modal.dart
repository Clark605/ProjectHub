import 'package:client/core/theme/app_icon_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:client/core/dialog/app_bottom_sheet.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tags/data/tag_repository.dart';
import 'package:client/features/tags/ui/widgets/attach_tag_results.dart';
import 'package:client/features/tags/ui/widgets/attach_tag_search_field.dart';
import 'package:client/core/extensions/context_extensions.dart';
import 'package:client/core/theme/app_spacing.dart';

class AttachTagModal extends StatefulWidget {
  const AttachTagModal({
    super.key,
    required this.projectId,
    required this.currentTags,
    required this.onTagSelected,
    this.repository,
  });

  final int projectId;
  final List<TagDto> currentTags;
  final ValueChanged<TagDto> onTagSelected;
  final TagRepository? repository;

  static Future<void> show(
    BuildContext context, {
    required int projectId,
    required List<TagDto> currentTags,
    required ValueChanged<TagDto> onTagSelected,
    TagRepository? repository,
  }) {
    return showAppBottomSheet<void>(
      context: context,
      builder: (_) => AttachTagModal(
        projectId: projectId,
        currentTags: currentTags,
        onTagSelected: onTagSelected,
        repository: repository,
      ),
    );
  }

  @override
  State<AttachTagModal> createState() => _AttachTagModalState();
}

class _AttachTagModalState extends State<AttachTagModal> {
  final _searchController = TextEditingController();
  TagRepository? _tagRepository;

  List<TagDto> _availableTags = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initRepoAndLoad();
    });
  }

  void _initRepoAndLoad() {
    _tagRepository = widget.repository;
    if (_tagRepository == null) {
      try {
        _tagRepository = context.read<TagRepository>();
      } on Object catch (_) {
        // Allows rendering in isolated tests without TagRepository
      }
    }
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);
    try {
      final tags =
          await _tagRepository?.getAvailableTagsForProject(widget.projectId) ??
          [];
      if (mounted) {
        setState(() {
          _availableTags = tags;
          _isLoading = false;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createAndSelectTag(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final repo = _tagRepository;
    if (repo == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final newTag = await repo.createProjectTag(widget.projectId, trimmed);
      if (mounted) {
        widget.onTagSelected(newTag);
        Navigator.of(context).pop();
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final query = _searchController.text.trim().toLowerCase();
    final attachedIds = widget.currentTags.map((t) => t.id).toSet();
    final filtered = _availableTags
        .where(
          (t) =>
              !attachedIds.contains(t.id) &&
              t.name.toLowerCase().contains(query),
        )
        .toList();
    final canCreate =
        query.isNotEmpty &&
        !_availableTags.any((t) => t.name.toLowerCase() == query);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSheetDragHandle(),
          AppSpacing.gapHSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.attachTagMax,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: AppIconSize.lg,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          AppSpacing.gapHMd,
          AttachTagSearchField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
          ),
          if (_error != null) ...[
            AppSpacing.gapHSm,
            Text(_error!, style: const TextStyle(color: AppColors.error)),
          ],
          AppSpacing.gapHMd,
          AttachTagResults(
            isLoading: _isLoading,
            canCreate: canCreate,
            query: query,
            filteredTags: filtered,
            onCreateTag: _createAndSelectTag,
            onSelectTag: (tag) {
              widget.onTagSelected(tag);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
