using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Hybrid;
using Microsoft.Extensions.Logging;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.TagDtos;
using ProjectHub.Api.DTOs.TaskDtos;
using ProjectHub.Api.Exceptions;
using ProjectHub.Api.Extensions;
using ProjectHub.Api.Hubs;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services.Interfaces;
using Task = System.Threading.Tasks.Task;
using TaskEntity = ProjectHub.Api.Models.Task;

namespace ProjectHub.Api.Services;

public class TagService : ITagService
{
    private readonly AppDbContext _context;
    private readonly HybridCache _cache;
    private readonly IHubContext<WorkspaceHub> _hubContext;
    private readonly ILogger<TagService> _logger;

    public TagService(
        AppDbContext context,
        HybridCache cache,
        IHubContext<WorkspaceHub> hubContext,
        ILogger<TagService> logger)
    {
        _context = context;
        _cache = cache;
        _hubContext = hubContext;
        _logger = logger;
    }

    public async Task<TagResponseDto> CreateWorkspaceTagAsync(string userId, int workspaceId, CreateTagRequestDto request)
    {
        var workspace = await _context.WorkSpaces.FirstOrDefaultAsync(w => w.Id == workspaceId);
        if (workspace == null)
        {
            _logger.LogWarning("Workspace with ID {WorkspaceId} not found", workspaceId);
            throw new KeyNotFoundException($"Workspace with ID {workspaceId} not found.");
        }

        var member = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == workspaceId);

        if (member == null || member.Role != WorkspaceRoles.Owner.ToString())
        {
            _logger.LogWarning("User {UserId} is not authorized to create workspace tags in workspace {WorkspaceId}", userId, workspaceId);
            throw new ForbiddenException("Only workspace owners can create workspace-level tags.");
        }

        var normalizedName = request.Name.Trim();
        var color = TagPalette.GetColorForTag(normalizedName);

        var tag = new Tag
        {
            WorkspaceId = workspaceId,
            ProjectId = null,
            Name = normalizedName,
            Color = color,
            CreatedAt = DateTime.UtcNow
        };

        _context.Tags.Add(tag);
        await _context.SaveChangesAsync();

        return new TagResponseDto
        {
            Id = tag.Id,
            WorkspaceId = tag.WorkspaceId,
            ProjectId = tag.ProjectId,
            Name = tag.Name,
            Color = tag.Color,
            CreatedAt = tag.CreatedAt
        };
    }

    public async Task<TagResponseDto> CreateProjectTagAsync(string userId, int projectId, CreateTagRequestDto request)
    {
        var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == projectId);
        if (project == null)
        {
            _logger.LogWarning("Project with ID {ProjectId} not found", projectId);
            throw new KeyNotFoundException($"Project with ID {projectId} not found.");
        }

        var member = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == project.WorkspaceId);

        if (member == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, project.WorkspaceId);
            throw new KeyNotFoundException($"Project with ID {projectId} not found for user {userId}");
        }

        bool isOwner = member.Role == WorkspaceRoles.Owner.ToString();
        bool isProjectCreator = project.CreatedBy == userId;

        if (!isOwner && !isProjectCreator)
        {
            _logger.LogWarning("User {UserId} is not authorized to create project tags for project {ProjectId}", userId, projectId);
            throw new ForbiddenException("Only workspace owners or project creators can create project-level tags.");
        }

        var normalizedName = request.Name.Trim();
        var color = TagPalette.GetColorForTag(normalizedName);

        var tag = new Tag
        {
            WorkspaceId = project.WorkspaceId,
            ProjectId = projectId,
            Name = normalizedName,
            Color = color,
            CreatedAt = DateTime.UtcNow
        };

        _context.Tags.Add(tag);
        await _context.SaveChangesAsync();

        return new TagResponseDto
        {
            Id = tag.Id,
            WorkspaceId = tag.WorkspaceId,
            ProjectId = tag.ProjectId,
            Name = tag.Name,
            Color = tag.Color,
            CreatedAt = tag.CreatedAt
        };
    }

    public async Task<IEnumerable<TagResponseDto>> GetAvailableTagsForProjectAsync(string userId, int projectId)
    {
        var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == projectId);
        if (project == null)
        {
            _logger.LogWarning("Project with ID {ProjectId} not found", projectId);
            throw new KeyNotFoundException($"Project with ID {projectId} not found.");
        }

        var isMember = await _context.WorkspaceMembers
            .AnyAsync(wm => wm.UserId == userId && wm.Workspace.Id == project.WorkspaceId);

        if (!isMember)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, project.WorkspaceId);
            throw new KeyNotFoundException($"Project with ID {projectId} not found for user {userId}");
        }

        var tags = await _context.Tags
            .Where(t => t.WorkspaceId == project.WorkspaceId && (t.ProjectId == null || t.ProjectId == projectId))
            .OrderBy(t => t.Name)
            .Select(t => new TagResponseDto
            {
                Id = t.Id,
                WorkspaceId = t.WorkspaceId,
                ProjectId = t.ProjectId,
                Name = t.Name,
                Color = t.Color,
                CreatedAt = t.CreatedAt
            })
            .ToListAsync();

        return tags;
    }

    public async Task<IEnumerable<TagResponseDto>> GetWorkspaceTagsAsync(string userId, int workspaceId)
    {
        var isMember = await _context.WorkspaceMembers
            .AnyAsync(wm => wm.UserId == userId && wm.Workspace.Id == workspaceId);

        if (!isMember)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, workspaceId);
            throw new KeyNotFoundException($"Workspace with ID {workspaceId} not found for user {userId}");
        }

        var tags = await _context.Tags
            .Where(t => t.WorkspaceId == workspaceId && t.ProjectId == null)
            .OrderBy(t => t.Name)
            .Select(t => new TagResponseDto
            {
                Id = t.Id,
                WorkspaceId = t.WorkspaceId,
                ProjectId = t.ProjectId,
                Name = t.Name,
                Color = t.Color,
                CreatedAt = t.CreatedAt
            })
            .ToListAsync();

        return tags;
    }

    public async Task<TaskResponseDto> AttachTagToTaskAsync(string userId, int taskId, int tagId)
    {
        var task = await _context.Tasks
            .Include(t => t.Project)
            .Include(t => t.Creator)
            .Include(t => t.Assignee)
            .Include(t => t.Comments)
            .Include(t => t.TaskTags)
                .ThenInclude(tt => tt.Tag)
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null)
        {
            _logger.LogWarning("Task with ID {TaskId} not found", taskId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found.");
        }

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == task.Project.WorkspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, task.Project.WorkspaceId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found for user {userId}");
        }

        bool isOwner = workspaceMember.Role == WorkspaceRoles.Owner.ToString();
        bool isCreator = task.CreatedBy == userId;
        bool isAssignee = task.AssigneeId == userId;

        if (!isOwner && !isCreator && !isAssignee)
        {
            _logger.LogWarning("User {UserId} does not have permission to edit task {TaskId}", userId, taskId);
            throw new ForbiddenException($"User {userId} does not have permission to update task {taskId}.");
        }

        var tag = await _context.Tags.FirstOrDefaultAsync(t => t.Id == tagId);
        if (tag == null)
        {
            _logger.LogWarning("Tag with ID {TagId} not found", tagId);
            throw new KeyNotFoundException($"Tag with ID {tagId} not found.");
        }

        if (tag.WorkspaceId != task.Project.WorkspaceId || (tag.ProjectId != null && tag.ProjectId != task.ProjectId))
        {
            _logger.LogWarning("Tag {TagId} is not available for project {ProjectId}", tagId, task.ProjectId);
            throw new ArgumentException("Tag is not available for this project.");
        }

        if (task.TaskTags.Any(tt => tt.TagId == tagId))
        {
            return MapToDto(task);
        }

        if (task.TaskTags.Count >= 5)
        {
            _logger.LogWarning("Task {TaskId} already has 5 tags", taskId);
            throw new InvalidOperationException("A task cannot have more than 5 tags.");
        }

        var taskTag = new TaskTag
        {
            TaskId = taskId,
            TagId = tagId,
            Tag = tag,
            Task = task
        };

        task.TaskTags.Add(taskTag);
        task.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        await _cache.RemoveByTagAsync($"project:{task.ProjectId}:tasks");

        var response = MapToDto(task);
        await _hubContext.Clients.Group($"workspace-{task.Project.WorkspaceId}")
            .SendAsync("TaskUpdated", response);

        return response;
    }

    public async Task<TaskResponseDto> DetachTagFromTaskAsync(string userId, int taskId, int tagId)
    {
        var task = await _context.Tasks
            .Include(t => t.Project)
            .Include(t => t.Creator)
            .Include(t => t.Assignee)
            .Include(t => t.Comments)
            .Include(t => t.TaskTags)
                .ThenInclude(tt => tt.Tag)
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null)
        {
            _logger.LogWarning("Task with ID {TaskId} not found", taskId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found.");
        }

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == task.Project.WorkspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, task.Project.WorkspaceId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found for user {userId}");
        }

        bool isOwner = workspaceMember.Role == WorkspaceRoles.Owner.ToString();
        bool isCreator = task.CreatedBy == userId;
        bool isAssignee = task.AssigneeId == userId;

        if (!isOwner && !isCreator && !isAssignee)
        {
            _logger.LogWarning("User {UserId} does not have permission to edit task {TaskId}", userId, taskId);
            throw new ForbiddenException($"User {userId} does not have permission to update task {taskId}.");
        }

        var existingJoin = task.TaskTags.FirstOrDefault(tt => tt.TagId == tagId);
        if (existingJoin != null)
        {
            task.TaskTags.Remove(existingJoin);
            task.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
            await _cache.RemoveByTagAsync($"project:{task.ProjectId}:tasks");
        }

        var response = MapToDto(task);
        await _hubContext.Clients.Group($"workspace-{task.Project.WorkspaceId}")
            .SendAsync("TaskUpdated", response);

        return response;
    }

    public async Task DeleteTagAsync(string userId, int tagId)
    {
        var tag = await _context.Tags.FirstOrDefaultAsync(t => t.Id == tagId);
        if (tag == null)
        {
            _logger.LogWarning("Tag with ID {TagId} not found", tagId);
            throw new KeyNotFoundException($"Tag with ID {tagId} not found.");
        }

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == tag.WorkspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, tag.WorkspaceId);
            throw new KeyNotFoundException($"Tag with ID {tagId} not found for user {userId}");
        }

        bool isOwner = workspaceMember.Role == WorkspaceRoles.Owner.ToString();

        if (tag.ProjectId == null)
        {
            if (!isOwner)
            {
                _logger.LogWarning("User {UserId} is not authorized to delete workspace tag {TagId}", userId, tagId);
                throw new ForbiddenException("Only workspace owners can delete workspace-level tags.");
            }
        }
        else
        {
            var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == tag.ProjectId);
            bool isProjectCreator = project != null && project.CreatedBy == userId;

            if (!isOwner && !isProjectCreator)
            {
                _logger.LogWarning("User {UserId} is not authorized to delete project tag {TagId}", userId, tagId);
                throw new ForbiddenException("Only workspace owners or project creators can delete project-level tags.");
            }
        }

        var affectedProjectId = tag.ProjectId;
        var affectedWorkspaceId = tag.WorkspaceId;

        _context.Tags.Remove(tag);
        await _context.SaveChangesAsync();

        if (affectedProjectId.HasValue)
        {
            await _cache.RemoveByTagAsync($"project:{affectedProjectId.Value}:tasks");
        }
        else
        {
            await _cache.RemoveByTagAsync($"workspace:{affectedWorkspaceId}:tasks");
        }
    }

    private static TaskResponseDto MapToDto(TaskEntity task)
    {
        return new TaskResponseDto
        {
            Id = task.Id,
            ProjectId = task.ProjectId,
            ProjectName = task.Project?.Name,
            Title = task.Title,
            Description = task.Description,
            Status = task.Status.ToWireString(),
            Priority = task.Priority.ToWireString(),
            AssigneeId = task.AssigneeId,
            AssigneeName = task.Assignee?.Name,
            CreatedBy = task.CreatedBy,
            CreatedByName = task.Creator?.Name ?? string.Empty,
            DueDate = task.DueDate,
            CreatedAt = task.CreatedAt,
            UpdatedAt = task.UpdatedAt,
            CommentCount = task.Comments?.Count ?? 0,
            Tags = task.TaskTags?.Select(tt => new TagResponseDto
            {
                Id = tt.Tag.Id,
                WorkspaceId = tt.Tag.WorkspaceId,
                ProjectId = tt.Tag.ProjectId,
                Name = tt.Tag.Name,
                Color = tt.Tag.Color,
                CreatedAt = tt.Tag.CreatedAt
            }).ToList() ?? []
        };
    }
}
