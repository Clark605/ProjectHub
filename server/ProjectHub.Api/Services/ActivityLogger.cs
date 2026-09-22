using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.ActivityDtos;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services.Interfaces;
using Task = System.Threading.Tasks.Task;

namespace ProjectHub.Api.Services;

public class ActivityLogger : IActivityLogger
{
    private readonly AppDbContext _context;
    private readonly ILogger<ActivityLogger> _logger;

    public ActivityLogger(AppDbContext context, ILogger<ActivityLogger> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task LogAsync(
        int workspaceId,
        string actorId,
        string actorName,
        ActivityEventType eventType,
        int? projectId = null,
        int? taskId = null,
        object? metadata = null)
    {
        try
        {
            string? serializedMetadata = metadata != null ? JsonSerializer.Serialize(metadata) : null;
            if (serializedMetadata != null && serializedMetadata.Length > 4000)
            {
                serializedMetadata = serializedMetadata[..4000];
            }

            var activity = new ActivityEvent
            {
                WorkspaceId = workspaceId,
                ActorId = actorId,
                ActorName = actorName,
                EventType = eventType,
                ProjectId = projectId,
                TaskId = taskId,
                Metadata = serializedMetadata,
                CreatedAt = DateTime.UtcNow
            };

            _context.ActivityEvents.Add(activity);
            await _context.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to log activity event {EventType} for workspace {WorkspaceId}", eventType, workspaceId);
        }
    }

    public async Task<IEnumerable<ActivityEventDto>> GetWorkspaceActivitiesAsync(
        int workspaceId,
        int limit = 20,
        string? eventType = null,
        string? search = null,
        int? projectId = null,
        DateTime? startDate = null,
        DateTime? endDate = null,
        string? sortBy = null,
        bool sortDescending = true)
    {
        var clampedLimit = Math.Clamp(limit, 1, 100);
        var query = _context.ActivityEvents
            .AsNoTracking()
            .Where(a => a.WorkspaceId == workspaceId);

        if (!string.IsNullOrWhiteSpace(eventType))
        {
            query = query.Where(a => a.EventType.ToString() == eventType || a.EventType.ToString().StartsWith(eventType));
        }

        if (!string.IsNullOrWhiteSpace(search))
        {
            query = query.Where(a => a.ActorName.Contains(search) || (a.Metadata != null && a.Metadata.Contains(search)));
        }

        if (projectId.HasValue)
        {
            query = query.Where(a => a.ProjectId == projectId.Value);
        }

        if (startDate.HasValue)
        {
            query = query.Where(a => a.CreatedAt >= startDate.Value);
        }

        if (endDate.HasValue)
        {
            query = query.Where(a => a.CreatedAt <= endDate.Value);
        }

        query = (sortBy?.ToLowerInvariant(), sortDescending) switch
        {
            ("actor", true) => query.OrderByDescending(a => a.ActorName).ThenByDescending(a => a.CreatedAt),
            ("actor", false) => query.OrderBy(a => a.ActorName).ThenByDescending(a => a.CreatedAt),
            ("type", true) => query.OrderByDescending(a => a.EventType).ThenByDescending(a => a.CreatedAt),
            ("type", false) => query.OrderBy(a => a.EventType).ThenByDescending(a => a.CreatedAt),
            (_, false) => query.OrderBy(a => a.CreatedAt),
            _ => query.OrderByDescending(a => a.CreatedAt)
        };

        return await query
            .Take(clampedLimit)
            .Select(a => new ActivityEventDto
            {
                Id = a.Id,
                WorkspaceId = a.WorkspaceId,
                ProjectId = a.ProjectId,
                TaskId = a.TaskId,
                ActorId = a.ActorId,
                ActorName = a.ActorName,
                EventType = a.EventType.ToString(),
                Metadata = a.Metadata,
                CreatedAt = a.CreatedAt
            })
            .ToListAsync();
    }

    public async Task<IEnumerable<ActivityEventDto>> GetProjectActivitiesAsync(int projectId, int limit = 50)
    {
        var clampedLimit = Math.Clamp(limit, 1, 100);
        return await _context.ActivityEvents
            .AsNoTracking()
            .Where(a => a.ProjectId == projectId)
            .OrderByDescending(a => a.CreatedAt)
            .Take(clampedLimit)
            .Select(a => new ActivityEventDto
            {
                Id = a.Id,
                WorkspaceId = a.WorkspaceId,
                ProjectId = a.ProjectId,
                TaskId = a.TaskId,
                ActorId = a.ActorId,
                ActorName = a.ActorName,
                EventType = a.EventType.ToString(),
                Metadata = a.Metadata,
                CreatedAt = a.CreatedAt
            })
            .ToListAsync();
    }
}
