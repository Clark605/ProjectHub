import 'package:flutter_test/flutter_test.dart';

import 'package:client/core/utils/permission_checker.dart';

void main() {
  group('PermissionChecker Project Permissions', () {
    const ownerUserId = 'user-owner-123';
    const creatorUserId = 'user-creator-456';
    const otherUserId = 'user-other-789';

    test('Workspace Owner can edit project regardless of creator', () {
      final canEdit = PermissionChecker.canEditProject(
        role: WorkspaceRole.owner,
        projectCreatorId: creatorUserId,
        currentUserId: ownerUserId,
      );
      expect(canEdit, isTrue);
    });

    test('Workspace Owner can delete project regardless of creator', () {
      final canDelete = PermissionChecker.canDeleteProject(
        role: WorkspaceRole.owner,
        projectCreatorId: creatorUserId,
        currentUserId: ownerUserId,
      );
      expect(canDelete, isTrue);
    });

    test('Member who created the project can edit it', () {
      final canEdit = PermissionChecker.canEditProject(
        role: WorkspaceRole.member,
        projectCreatorId: creatorUserId,
        currentUserId: creatorUserId,
      );
      expect(canEdit, isTrue);
    });

    test('Member who created the project can delete it', () {
      final canDelete = PermissionChecker.canDeleteProject(
        role: WorkspaceRole.member,
        projectCreatorId: creatorUserId,
        currentUserId: creatorUserId,
      );
      expect(canDelete, isTrue);
    });

    test('Member who is NOT the creator cannot edit project', () {
      final canEdit = PermissionChecker.canEditProject(
        role: WorkspaceRole.member,
        projectCreatorId: creatorUserId,
        currentUserId: otherUserId,
      );
      expect(canEdit, isFalse);
    });

    test('Member who is NOT the creator cannot delete project', () {
      final canDelete = PermissionChecker.canDeleteProject(
        role: WorkspaceRole.member,
        projectCreatorId: creatorUserId,
        currentUserId: otherUserId,
      );
      expect(canDelete, isFalse);
    });
  });
}
