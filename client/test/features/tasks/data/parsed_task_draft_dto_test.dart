import 'package:flutter_test/flutter_test.dart';

import 'package:client/features/tasks/data/models/parsed_task_draft_dto.dart';

void main() {
  group('ParsedTaskDraftDto', () {
    test('deserializes complete JSON payload correctly', () {
      final json = {
        'title': 'Test Stripe Payment Webhook',
        'description':
            'Ensure webhook processing handles customer checkout.\n\n- Test signature\n- Verify DB write',
        'priority': 'Urgent',
        'assigneeId': 'usr-123-abc',
        'assigneeName': 'Sarah Connor',
        'dueDate': '2026-10-09T17:00:00.000Z',
        'warnings': ['Could not resolve secondary assignee'],
      };

      final dto = ParsedTaskDraftDto.fromJson(json);

      expect(dto.title, 'Test Stripe Payment Webhook');
      expect(dto.description, contains('- Test signature'));
      expect(dto.priority, 'Urgent');
      expect(dto.assigneeId, 'usr-123-abc');
      expect(dto.assigneeName, 'Sarah Connor');
      expect(dto.dueDate, isNotNull);
      expect(dto.warnings.length, 1);
      expect(dto.warnings.first, contains('secondary assignee'));
    });

    test('deserializes minimal JSON payload with defaults', () {
      final json = {'title': 'Quick Task'};

      final dto = ParsedTaskDraftDto.fromJson(json);

      expect(dto.title, 'Quick Task');
      expect(dto.description, '');
      expect(dto.priority, 'Medium');
      expect(dto.assigneeId, isNull);
      expect(dto.assigneeName, isNull);
      expect(dto.dueDate, isNull);
      expect(dto.warnings, isEmpty);
    });

    test('serializes back to JSON', () {
      const dto = ParsedTaskDraftDto(
        title: 'Fix issue',
        description: 'Details here',
        priority: 'High',
        warnings: ['Warning 1'],
      );

      final json = dto.toJson();

      expect(json['title'], 'Fix issue');
      expect(json['description'], 'Details here');
      expect(json['priority'], 'High');
      expect(json['warnings'], ['Warning 1']);
    });
  });
}
