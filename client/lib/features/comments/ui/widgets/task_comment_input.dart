import 'package:flutter/material.dart';

import 'package:client/core/theme/app_colors.dart';

class TaskCommentInput extends StatefulWidget {
  const TaskCommentInput({
    super.key,
    required this.onSend,
    this.isSending = false,
  });

  final ValueChanged<String> onSend;
  final bool isSending;

  @override
  State<TaskCommentInput> createState() => _TaskCommentInputState();
}

class _TaskCommentInputState extends State<TaskCommentInput> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isSending) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Write a comment...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.isSending)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(Icons.send_rounded, size: 18),
              color: AppColors.primary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _submit,
            ),
        ],
      ),
    );
  }
}
