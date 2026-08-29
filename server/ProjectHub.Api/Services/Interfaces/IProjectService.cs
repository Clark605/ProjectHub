using ProjectHub.Api.DTOs.ProjectDtos;

namespace ProjectHub.Api.Services.Interfaces;

public interface IProjectService
{
    // Project CRUD
    Task<ProjectResponseDto> CreateProjectAsync(string userId, int workspaceId, CreateProjectRequestDto request);
    Task<IEnumerable<ProjectResponseDto>> GetProjectsByWorkspaceAsync(string userId, int workspaceId, string? status);
    Task<ProjectResponseDto> GetProjectByIdAsync(string userId, int projectId);
    Task<ProjectResponseDto> UpdateProjectAsync(string userId, int projectId, UpdateProjectRequestDto request);
    Task DeleteProjectAsync(string userId, int projectId);
}

