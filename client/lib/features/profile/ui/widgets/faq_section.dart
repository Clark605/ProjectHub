import 'package:flutter/material.dart';

class FaqSection extends StatelessWidget {
  const FaqSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Text(
                  'Help & FAQ',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Answers to common questions regarding workspaces, Kanban, and permissions.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            ),
            const SizedBox(height: 12),
            const _FaqItem(
              question: 'How do workspaces and roles work?',
              answer:
                  'Each workspace has an Owner and Members. Owners can rename or delete workspaces, and invite or remove members. All members have implicit access to collaborate on all projects within that workspace.',
            ),
            const _FaqItem(
              question: 'What happens when a member is removed?',
              answer:
                  'Removing a member automatically sets Assignee = null on all tasks assigned to that user in that workspace. This maintains task integrity without leaving dangling foreign key references.',
            ),
            const _FaqItem(
              question: 'Can archived projects still be edited?',
              answer:
                  'No. In accordance with ADR-0002, setting a project to Archived strictly freezes the project and all its Kanban tasks as read-only until explicitly restored to Active or Planning.',
            ),
            const _FaqItem(
              question: 'How does the "My Tasks" focus view work?',
              answer:
                  'My Tasks aggregates every task assigned to you across all projects in the active workspace via a single indexed query, grouped by urgency so you can focus on immediate deliverables.',
            ),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                  height: 1.45,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
