using System.Collections.Generic;
using System.Threading.Tasks;
using ProjectHub.Api.DTOs.TagDtos;
using ProjectHub.Api.DTOs.TaskDtos;

namespace ProjectHub.Api.Services.Interfaces;

public interface ITagService
{
    Task<TagResponseDto> CreateWorkspaceTagAsync(string userId, int workspaceId, CreateTagRequestDto request);
    Task<TagResponseDto> CreateProjectTagAsync(string userId, int projectId, CreateTagRequestDto request);
    Task<IEnumerable<TagResponseDto>> GetAvailableTagsForProjectAsync(string userId, int projectId);
    Task<IEnumerable<TagResponseDto>> GetWorkspaceTagsAsync(string userId, int workspaceId);
    Task<TaskResponseDto> AttachTagToTaskAsync(string userId, int taskId, int tagId);
    Task<TaskResponseDto> DetachTagFromTaskAsync(string userId, int taskId, int tagId);
    Task DeleteTagAsync(string userId, int tagId);
}

