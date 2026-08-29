
using ProjectHub.Api.DTOs.WorkSpaceDtos;

namespace ProjectHub.Api.Services.Interfaces;

public interface IWorkspaceService
{
    //Workspace Management
    Task<WorkspaceResponseDto> CreateWorkspaceAsync(string userId, CreateWorkspaceRequestDto request);
    Task<IEnumerable<WorkspaceResponseDto>> GetWorkspacesByUserIdAsync(string userId);
    Task<WorkspaceResponseDto> GetWorkspaceByIdAsync(string userId, int workspaceId);
    Task<WorkspaceResponseDto> UpdateWorkspaceAsync(string userId, int workspaceId, UpdateWorkspaceRequestDto request);
    Task DeleteWorkspaceAsync(string userId, int workspaceId);

    // Member Management
    Task<MemberResponseDto> AddMemberToWorkspaceAsync(string userId, int workspaceId, AddMemberDto request);
    Task RemoveMemberFromWorkspaceAsync(string userId, int workspaceId, string memberId);
    Task<IEnumerable<MemberResponseDto>> GetMembersByWorkspaceIdAsync(string userId, int workspaceId);
}

