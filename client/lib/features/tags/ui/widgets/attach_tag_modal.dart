import 'package:flutter/material.dart';

import 'package:client/core/di/injection.dart';
import 'package:client/core/theme/app_colors.dart';
import 'package:client/features/tags/data/models/tag_dto.dart';
import 'package:client/features/tags/data/tag_repository.dart';
import 'package:client/features/tags/ui/widgets/tag_chip.dart';

class AttachTagModal extends StatefulWidget {
  const AttachTagModal({
    super.key,
    required this.projectId,
    required this.currentTags,
    required this.onTagSelected,
  });

  final int projectId;
  final List<TagDto> currentTags;
  final ValueChanged<TagDto> onTagSelected;

  static Future<void> show(
    BuildContext context, {
    required int projectId,
    required List<TagDto> currentTags,
    required ValueChanged<TagDto> onTagSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AttachTagModal(
        projectId: projectId,
        currentTags: currentTags,
        onTagSelected: onTagSelected,
      ),
    );
  }

  @override
  State<AttachTagModal> createState() => _AttachTagModalState();
}

class _AttachTagModalState extends State<AttachTagModal> {
  final _searchController = TextEditingController();
  final _tagRepository = getIt<TagRepository>();

  List<TagDto> _availableTags = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);
    try {
      final tags = await _tagRepository.getAvailableTagsForProject(widget.projectId);
      if (mounted) setState(() { _availableTags = tags; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _createAndSelectTag(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final newTag = await _tagRepository.createProjectTag(widget.projectId, trimmed);
      if (mounted) {
        widget.onTagSelected(newTag);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final attachedIds = widget.currentTags.map((t) => t.id).toSet();
    final filtered = _availableTags
        .where((t) => !attachedIds.contains(t.id) && t.name.toLowerCase().contains(query))
        .toList();
    final canCreate = query.isNotEmpty && !_availableTags.any((t) => t.name.toLowerCase() == query);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Attach Tag (Max 5)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search or create tag...',
              prefixIcon: const Icon(Icons.search, size: 18),
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
          if (_error != null) ...[const SizedBox(height: 8), Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12))],
          const SizedBox(height: 14),
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator(strokeWidth: 2)))
          else ...[
            if (canCreate)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                title: Text('Create "$query"', style: const TextStyle(color: AppColors.primary, fontSize: 13)),
                onTap: () => _createAndSelectTag(query),
              ),
            if (filtered.isEmpty && !canCreate)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('No tags available', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filtered.map((tag) => TagChip(
                  tag: tag,
                  onTap: () {
                    widget.onTagSelected(tag);
                    Navigator.of(context).pop();
                  },
                )).toList(),
              ),
          ],
        ],
      ),
    );
  }
}
