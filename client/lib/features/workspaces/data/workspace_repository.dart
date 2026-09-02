import 'package:client/features/workspaces/data/models/create_workspace_request.dart';
import 'package:client/features/workspaces/data/models/workspace_dto.dart';

abstract class WorkspaceRepository {
  Future<List<WorkspaceDto>> getWorkspaces();
  Future<WorkspaceDto> getWorkspace(int id);
  Future<WorkspaceDto> createWorkspace(CreateWorkspaceRequest request);
}
