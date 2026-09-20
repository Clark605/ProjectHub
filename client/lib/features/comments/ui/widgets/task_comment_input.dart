import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 3,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
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
              color: theme.colorScheme.primary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _submit,
            ),
        ],
      ),
    );
  }
}
