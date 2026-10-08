import 'package:flutter_test/flutter_test.dart';
import 'package:client/features/dashboard/data/models/workspace_dashboard_dto.dart';

void main() {
  group('WorkspaceDashboardDto', () {
    test('fromJson parses server payload correctly', () {
      final serverJson = {
        'activeProjectsCount': 3,
        'inProgressTasksCount': 7,
        'urgentTasksCount': 2,
        'completedTasksCount': 12,
        'overdueTasksCount': 1,
        'dueThisWeekTasksCount': 4,
        'focusTasks': [
          {
            'id': 101,
            'projectId': 10,
            'projectName': 'Core API',
            'title': 'Implement auth tokens',
            'description': 'Refresh tokens flow',
            'status': 'InProgress',
            'priority': 'Urgent',
            'assigneeId': 'u1',
            'assigneeName': 'Alice',
            'createdBy': 'u2',
            'createdByName': 'Bob',
            'dueDate': '2026-10-15T12:00:00.000Z',
            'createdAt': '2026-10-01T08:00:00.000Z',
            'updatedAt': '2026-10-02T08:00:00.000Z',
            'commentCount': 3,
            'tags': [
              {
                'id': 1,
                'name': 'Backend',
                'color': 'indigo',
                'workspaceId': 1,
                'projectId': 10,
              }
            ],
          }
        ],
        'recentActivities': [
          {
            'id': 501,
            'workspaceId': 1,
            'projectId': 10,
            'taskId': 101,
            'actorId': 'u1',
            'actorName': 'Alice',
            'eventType': 'TaskCreated',
            'metadata': {'title': 'Implement auth tokens'},
            'createdAt': '2026-10-01T08:00:00.000Z',
          }
        ],
      };

      final dto = WorkspaceDashboardDto.fromJson(serverJson);

      expect(dto.activeProjectsCount, 3);
      expect(dto.inProgressTasksCount, 7);
      expect(dto.urgentTasksCount, 2);
      expect(dto.completedTasksCount, 12);
      expect(dto.overdueTasksCount, 1);
      expect(dto.dueThisWeekTasksCount, 4);


      // Verify focus tasks
      expect(dto.focusTasks.length, 1);
      expect(dto.focusTasks.first.id, 101);
      expect(dto.focusTasks.first.title, 'Implement auth tokens');
      expect(dto.focusTasks.first.priority, 'Urgent');

      // Verify recent activities
      expect(dto.recentActivities.length, 1);
      expect(dto.recentActivities.first.id, 501);
      expect(dto.recentActivities.first.actorName, 'Alice');
    });

    test('fromJson throws FormatException when required key is missing', () {
      final invalidJson = {
        'activeProjectsCount': 3,
        // inProgressTasksCount is missing!
        'urgentTasksCount': 2,
        'completedTasksCount': 12,
        'overdueTasksCount': 1,
        'dueThisWeekTasksCount': 4,
      };

      expect(
        () => WorkspaceDashboardDto.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromJson throws FormatException when required key is null', () {
      final invalidJson = {
        'activeProjectsCount': null,
        'inProgressTasksCount': 2,
        'urgentTasksCount': 2,
        'completedTasksCount': 12,
        'overdueTasksCount': 1,
        'dueThisWeekTasksCount': 4,
      };

      expect(
        () => WorkspaceDashboardDto.fromJson(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

