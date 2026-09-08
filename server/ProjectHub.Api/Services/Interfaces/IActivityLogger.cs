using ProjectHub.Api.DTOs.ActivityDtos;
using ProjectHub.Api.Models;
using Task = System.Threading.Tasks.Task;

namespace ProjectHub.Api.Services.Interfaces;

public interface IActivityLogger
{
    Task LogAsync(
        int workspaceId,
        string actorId,
        string actorName,
        ActivityEventType eventType,
        int? projectId = null,
        int? taskId = null,
        object? metadata = null);

    Task<IEnumerable<ActivityEventDto>> GetWorkspaceActivitiesAsync(int workspaceId, int limit = 20);
    Task<IEnumerable<ActivityEventDto>> GetProjectActivitiesAsync(int projectId, int limit = 50);
}
