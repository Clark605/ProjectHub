import 'package:client/features/workspaces/data/models/add_member_request.dart';
import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/member_dto.dart';
import 'package:client/features/workspaces/data/models/update_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';

abstract class WorkspaceRepository {
  Future<List<WorkspaceDto>> getWorkspaces();
  Future<WorkspaceDto> getWorkspace(int id);
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request);
  Future<WorkspaceDto> updateWorkspace(int id, UpdateWorkspaceRequest request);
  Future<void> deleteWorkspace(int id);
  Future<List<MemberDto>> getMembers(int workspaceId);
  Future<MemberDto> addMember(int workspaceId, AddMemberRequest request);
  Future<void> removeMember(int workspaceId, String userId);
}
