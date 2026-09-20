using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.TagDtos;
using ProjectHub.Api.DTOs.TaskDtos;
using ProjectHub.Api.Exceptions;
using ProjectHub.Api.Hubs;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services.Interfaces;
using Task = System.Threading.Tasks.Task;
using TaskEntity = ProjectHub.Api.Models.Task;

namespace ProjectHub.Api.Services;

public class TaskService : ITaskService
{
    private readonly AppDbContext _context;
    private readonly UserManager<AppUser> _userManager;
    private readonly IActivityLogger _activityLogger;
    private readonly IHubContext<WorkspaceHub> _hubContext;
    private readonly ILogger<TaskService> _logger;

    public TaskService(
        AppDbContext context,
        UserManager<AppUser> userManager,
        IActivityLogger activityLogger,
        IHubContext<WorkspaceHub> hubContext,
        ILogger<TaskService> logger)
    {
        _context = context;
        _userManager = userManager;
        _activityLogger = activityLogger;
        _hubContext = hubContext;
        _logger = logger;
    }

    public async Task<TaskResponseDto> CreateTaskAsync(string userId, int projectId, CreateTaskRequestDto request)
    {
        _logger.LogInformation("User {UserId} creating task '{Title}' in project {ProjectId}", userId, request.Title, projectId);

        var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == projectId);
        if (project == null)
        {
            _logger.LogWarning("Project with ID {ProjectId} not found", projectId);
            throw new KeyNotFoundException($"Project with ID {projectId} not found.");
        }

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == project.WorkspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, project.WorkspaceId);
            throw new KeyNotFoundException($"Project with ID {projectId} not found for user {userId}");
        }

        var creator = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
        if (creator == null)
        {
            _logger.LogWarning("User with ID {UserId} not found", userId);
            throw new KeyNotFoundException($"User with ID {userId} not found");
        }

        string? assigneeName = null;
        if (!string.IsNullOrWhiteSpace(request.AssigneeId))
        {
            var isAssigneeInWorkspace = await _context.WorkspaceMembers
                .AnyAsync(wm => wm.Workspace.Id == project.WorkspaceId && wm.UserId == request.AssigneeId);

            if (!isAssigneeInWorkspace)
            {
                _logger.LogWarning("Assignee user {AssigneeId} is not a member of workspace {WorkspaceId}", request.AssigneeId, project.WorkspaceId);
                throw new ArgumentException($"User with ID '{request.AssigneeId}' is not a member of this workspace.");
            }

            var assigneeUser = await _context.Users.FirstOrDefaultAsync(u => u.Id == request.AssigneeId);
            assigneeName = assigneeUser?.Name;
        }

        var priority = !string.IsNullOrWhiteSpace(request.Priority)
            ? request.Priority.Trim()
            : TaskItemPriority.Medium.ToString();

        var task = new TaskEntity
        {
            ProjectId = projectId,
            Title = request.Title.Trim(),
            Description = request.Description?.Trim() ?? string.Empty,
            Status = TaskItemStatus.Backlog.ToString(),
            Priority = priority,
            AssigneeId = string.IsNullOrWhiteSpace(request.AssigneeId) ? null : request.AssigneeId,
            CreatedBy = userId,
            DueDate = request.DueDate,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Tasks.Add(task);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Task {TaskId} created successfully in project {ProjectId}", task.Id, projectId);

        List<TagResponseDto> attachedTags = [];
        if (request.TagIds != null && request.TagIds.Count > 0)
        {
            var distinctTagIds = request.TagIds.Distinct().Take(5).ToList();
            var validTags = await _context.Tags
                .Where(t => t.WorkspaceId == project.WorkspaceId && (t.ProjectId == null || t.ProjectId == projectId) && distinctTagIds.Contains(t.Id))
                .ToListAsync();

            foreach (var tagEntity in validTags)
            {
                _context.TaskTags.Add(new TaskTag { TaskId = task.Id, TagId = tagEntity.Id });
            }
            await _context.SaveChangesAsync();

            attachedTags = validTags.Select(t => new TagResponseDto
            {
                Id = t.Id,
                WorkspaceId = t.WorkspaceId,
                ProjectId = t.ProjectId,
                Name = t.Name,
                Color = t.Color,
                CreatedAt = t.CreatedAt
            }).ToList();
        }

        await _activityLogger.LogAsync(
            project.WorkspaceId,
            userId,
            creator.Name,
            ActivityEventType.TaskCreated,
            projectId: task.ProjectId,
            taskId: task.Id,
            metadata: new { task.Title, task.Status, task.Priority });

        var responseDto = new TaskResponseDto
        {
            Id = task.Id,
            ProjectId = task.ProjectId,
            ProjectName = project.Name,
            Title = task.Title,
            Description = task.Description,
            Status = task.Status,
            Priority = task.Priority,
            AssigneeId = task.AssigneeId,
            AssigneeName = assigneeName,
            CreatedBy = task.CreatedBy,
            CreatedByName = creator.Name,
            DueDate = task.DueDate,
            CreatedAt = task.CreatedAt,
            UpdatedAt = task.UpdatedAt,
            CommentCount = 0,
            Tags = attachedTags
        };

        await _hubContext.Clients.Group($"workspace-{project.WorkspaceId}")
            .SendAsync("TaskCreated", responseDto);

        return responseDto;
    }

    public async Task<IEnumerable<TaskResponseDto>> GetTasksByProjectAsync(
        string userId,
        int projectId,
        string? status,
        string? assigneeId,
        string? priority)
    {
        var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == projectId);
        if (project == null)
        {
            _logger.LogWarning("Project with ID {ProjectId} not found", projectId);
            throw new KeyNotFoundException($"Project with ID {projectId} not found.");
        }

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == project.WorkspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, project.WorkspaceId);
            throw new KeyNotFoundException($"Project with ID {projectId} not found for user {userId}");
        }

        var query = _context.Tasks
            .Include(t => t.Creator)
            .Include(t => t.Assignee)
            .Include(t => t.Comments)
            .Include(t => t.TaskTags)
                .ThenInclude(tt => tt.Tag)
            .Where(t => t.ProjectId == projectId);

        if (!string.IsNullOrWhiteSpace(status))
        {
            query = query.Where(t => t.Status.ToLower() == status.Trim().ToLower());
        }

        if (!string.IsNullOrWhiteSpace(assigneeId))
        {
            query = query.Where(t => t.AssigneeId == assigneeId.Trim());
        }

        if (!string.IsNullOrWhiteSpace(priority))
        {
            query = query.Where(t => t.Priority.ToLower() == priority.Trim().ToLower());
        }

        var tasks = await query
            .OrderByDescending(t => t.CreatedAt)
            .Select(t => new TaskResponseDto
            {
                Id = t.Id,
                ProjectId = t.ProjectId,
                Title = t.Title,
                Description = t.Description,
                Status = t.Status,
                Priority = t.Priority,
                AssigneeId = t.AssigneeId,
                AssigneeName = t.Assignee != null ? t.Assignee.Name : null,
                CreatedBy = t.CreatedBy,
                CreatedByName = t.Creator.Name,
                DueDate = t.DueDate,
                CreatedAt = t.CreatedAt,
                UpdatedAt = t.UpdatedAt,
                CommentCount = t.Comments.Count,
                Tags = t.TaskTags.Select(tt => new TagResponseDto
                {
                    Id = tt.Tag.Id,
                    WorkspaceId = tt.Tag.WorkspaceId,
                    ProjectId = tt.Tag.ProjectId,
                    Name = tt.Tag.Name,
                    Color = tt.Tag.Color,
                    CreatedAt = tt.Tag.CreatedAt
                }).ToList()
            })
            .ToListAsync();

        return tasks;
    }

    public async Task<TaskResponseDto> GetTaskByIdAsync(string userId, int taskId)
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

        return MapToDto(task);
    }

    public async Task<TaskResponseDto> UpdateTaskAsync(string userId, int taskId, UpdateTaskRequestDto request)
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
            _logger.LogWarning("User {UserId} does not have permission to update task {TaskId}", userId, taskId);
            throw new ForbiddenException($"User {userId} does not have permission to update task {taskId}.");
        }

        string? assigneeName = null;
        if (!string.IsNullOrWhiteSpace(request.AssigneeId))
        {
            var isAssigneeInWorkspace = await _context.WorkspaceMembers
                .AnyAsync(wm => wm.Workspace.Id == task.Project.WorkspaceId && wm.UserId == request.AssigneeId);

            if (!isAssigneeInWorkspace)
            {
                _logger.LogWarning("Assignee user {AssigneeId} is not a member of workspace {WorkspaceId}", request.AssigneeId, task.Project.WorkspaceId);
                throw new ArgumentException($"User with ID '{request.AssigneeId}' is not a member of this workspace.");
            }

            var assigneeUser = await _context.Users.FirstOrDefaultAsync(u => u.Id == request.AssigneeId);
            assigneeName = assigneeUser?.Name;
        }

        task.Title = request.Title.Trim();
        task.Description = request.Description?.Trim() ?? string.Empty;
        task.Priority = request.Priority.Trim();
        task.AssigneeId = string.IsNullOrWhiteSpace(request.AssigneeId) ? null : request.AssigneeId;
        task.DueDate = request.DueDate;
        task.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        _logger.LogInformation("Task {TaskId} updated successfully", taskId);

        var response = MapToDto(task, assigneeName: assigneeName);

        await _hubContext.Clients.Group($"workspace-{task.Project.WorkspaceId}")
            .SendAsync("TaskUpdated", response);

        return response;
    }

    public async Task DeleteTaskAsync(string userId, int taskId)
    {
        var task = await _context.Tasks
            .Include(t => t.Project)
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

        if (!isOwner && !isCreator)
        {
            _logger.LogWarning("User {UserId} is not authorized to delete task {TaskId}", userId, taskId);
            throw new ForbiddenException($"User {userId} is not authorized to delete task {taskId}.");
        }

        var workspaceId = task.Project.WorkspaceId;
        var projectId = task.ProjectId;
        var taskTitle = task.Title;

        _context.Tasks.Remove(task);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Task {TaskId} deleted successfully by user {UserId}", taskId, userId);

        var actor = await _userManager.FindByIdAsync(userId);
        await _activityLogger.LogAsync(
            workspaceId,
            userId,
            actor?.Name ?? userId,
            ActivityEventType.TaskDeleted,
            projectId: projectId,
            taskId: taskId,
            metadata: new { Title = taskTitle });

        await _hubContext.Clients.Group($"workspace-{workspaceId}")
            .SendAsync("TaskDeleted", new { TaskId = taskId, ProjectId = projectId });
    }

    public async Task<TaskResponseDto> UpdateTaskStatusAsync(string userId, int taskId, UpdateTaskStatusDto request)
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
            _logger.LogWarning("User {UserId} does not have permission to change status of task {TaskId}", userId, taskId);
            throw new ForbiddenException($"User {userId} does not have permission to update task {taskId}.");
        }

        var oldStatus = task.Status;
        task.Status = request.Status.Trim();
        task.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        _logger.LogInformation("Task {TaskId} status updated to '{Status}'", taskId, task.Status);

        var actor = await _userManager.FindByIdAsync(userId);
        await _activityLogger.LogAsync(
            task.Project.WorkspaceId,
            userId,
            actor?.Name ?? userId,
            ActivityEventType.TaskStatusChanged,
            projectId: task.ProjectId,
            taskId: task.Id,
            metadata: new { task.Title, OldStatus = oldStatus, NewStatus = task.Status });

        var response = MapToDto(task);

        await _hubContext.Clients.Group($"workspace-{task.Project.WorkspaceId}")
            .SendAsync("TaskStatusChanged", response);

        return response;
    }

    public async Task<TaskResponseDto> UpdateTaskAssigneeAsync(string userId, int taskId, UpdateTaskAssigneeDto request)
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

        string? assigneeName = null;
        if (!string.IsNullOrWhiteSpace(request.AssigneeId))
        {
            var isAssigneeInWorkspace = await _context.WorkspaceMembers
                .AnyAsync(wm => wm.Workspace.Id == task.Project.WorkspaceId && wm.UserId == request.AssigneeId);

            if (!isAssigneeInWorkspace)
            {
                _logger.LogWarning("Assignee user {AssigneeId} is not a member of workspace {WorkspaceId}", request.AssigneeId, task.Project.WorkspaceId);
                throw new ArgumentException($"User with ID '{request.AssigneeId}' is not a member of this workspace.");
            }

            var assigneeUser = await _context.Users.FirstOrDefaultAsync(u => u.Id == request.AssigneeId);
            assigneeName = assigneeUser?.Name;
        }

        task.AssigneeId = string.IsNullOrWhiteSpace(request.AssigneeId) ? null : request.AssigneeId;
        task.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        _logger.LogInformation("Task {TaskId} assignee updated to '{AssigneeId}'", taskId, task.AssigneeId);

        var assignActor = await _userManager.FindByIdAsync(userId);
        await _activityLogger.LogAsync(
            task.Project.WorkspaceId,
            userId,
            assignActor?.Name ?? userId,
            ActivityEventType.TaskAssigned,
            projectId: task.ProjectId,
            taskId: task.Id,
            metadata: new { task.Title, AssigneeId = task.AssigneeId, AssigneeName = assigneeName });

        var response = MapToDto(task, assigneeName: assigneeName);

        await _hubContext.Clients.Group($"workspace-{task.Project.WorkspaceId}")
            .SendAsync("TaskAssigned", response);

        return response;
    }

    public async Task<IEnumerable<TaskResponseDto>> GetMyTasksAsync(string userId, int workspaceId)
    {
        _logger.LogInformation("Fetching tasks assigned to user {UserId} in workspace {WorkspaceId}", userId, workspaceId);

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == workspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, workspaceId);
            throw new KeyNotFoundException($"Workspace with ID {workspaceId} not found for user {userId}");
        }

        var tasks = await _context.Tasks
            .Include(t => t.Project)
            .Include(t => t.Creator)
            .Include(t => t.Assignee)
            .Include(t => t.Comments)
            .Include(t => t.TaskTags)
                .ThenInclude(tt => tt.Tag)
            .Where(t => t.Project.WorkspaceId == workspaceId && t.AssigneeId == userId)
            .OrderByDescending(t => t.CreatedAt)
            .Select(t => new TaskResponseDto
            {
                Id = t.Id,
                ProjectId = t.ProjectId,
                ProjectName = t.Project.Name,
                Title = t.Title,
                Description = t.Description,
                Status = t.Status,
                Priority = t.Priority,
                AssigneeId = t.AssigneeId,
                AssigneeName = t.Assignee != null ? t.Assignee.Name : null,
                CreatedBy = t.CreatedBy,
                CreatedByName = t.Creator.Name,
                DueDate = t.DueDate,
                CreatedAt = t.CreatedAt,
                UpdatedAt = t.UpdatedAt,
                CommentCount = t.Comments.Count,
                Tags = t.TaskTags.Select(tt => new TagResponseDto
                {
                    Id = tt.Tag.Id,
                    WorkspaceId = tt.Tag.WorkspaceId,
                    ProjectId = tt.Tag.ProjectId,
                    Name = tt.Tag.Name,
                    Color = tt.Tag.Color,
                    CreatedAt = tt.Tag.CreatedAt
                }).ToList()
            })
            .ToListAsync();

        return tasks;
    }

    private static TaskResponseDto MapToDto(TaskEntity task, string? assigneeName = null, string? creatorName = null, string? projectName = null)
    {
        return new TaskResponseDto
        {
            Id = task.Id,
            ProjectId = task.ProjectId,
            ProjectName = projectName ?? task.Project?.Name,
            Title = task.Title,
            Description = task.Description,
            Status = task.Status,
            Priority = task.Priority,
            AssigneeId = task.AssigneeId,
            AssigneeName = assigneeName ?? task.Assignee?.Name,
            CreatedBy = task.CreatedBy,
            CreatedByName = creatorName ?? task.Creator?.Name ?? string.Empty,
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
