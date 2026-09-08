
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.TaskDtos;
using ProjectHub.Api.Exceptions;
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
    private readonly ILogger<TaskService> _logger;

    public TaskService(
        AppDbContext context,
        UserManager<AppUser> userManager,
        IActivityLogger activityLogger,
        ILogger<TaskService> logger)
    {
        _context = context;
        _userManager = userManager;
        _activityLogger = activityLogger;
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

        await _activityLogger.LogAsync(
            project.WorkspaceId,
            userId,
            creator.Name,
            ActivityEventType.TaskCreated,
            projectId: task.ProjectId,
            taskId: task.Id,
            metadata: new { task.Title, task.Status, task.Priority });

        return new TaskResponseDto
        {
            Id = task.Id,
            ProjectId = task.ProjectId,
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
            UpdatedAt = task.UpdatedAt
        };
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
                UpdatedAt = t.UpdatedAt
            })
            .ToListAsync();

        return tasks;
    }

    public async Task<TaskResponseDto> GetTaskByIdAsync(string userId, int taskId)
    {
        var task = await _context.Tasks
            .Include(t => t.Creator)
            .Include(t => t.Assignee)
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null)
        {
            _logger.LogWarning("Task with ID {TaskId} not found", taskId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found.");
        }

        var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == task.ProjectId);
        if (project == null)
        {
            _logger.LogWarning("Project with ID {ProjectId} not found for task {TaskId}", task.ProjectId, taskId);
            throw new KeyNotFoundException($"Project for task {taskId} not found.");
        }

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == project.WorkspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, project.WorkspaceId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found for user {userId}");
        }

        return new TaskResponseDto
        {
            Id = task.Id,
            ProjectId = task.ProjectId,
            Title = task.Title,
            Description = task.Description,
            Status = task.Status,
            Priority = task.Priority,
            AssigneeId = task.AssigneeId,
            AssigneeName = task.Assignee?.Name,
            CreatedBy = task.CreatedBy,
            CreatedByName = task.Creator.Name,
            DueDate = task.DueDate,
            CreatedAt = task.CreatedAt,
            UpdatedAt = task.UpdatedAt
        };
    }

    public async Task<TaskResponseDto> UpdateTaskAsync(string userId, int taskId, UpdateTaskRequestDto request)
    {
        var task = await _context.Tasks
            .Include(t => t.Creator)
            .Include(t => t.Assignee)
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null)
        {
            _logger.LogWarning("Task with ID {TaskId} not found", taskId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found.");
        }

        var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == task.ProjectId);
        if (project == null)
        {
            _logger.LogWarning("Project with ID {ProjectId} not found for task {TaskId}", task.ProjectId, taskId);
            throw new KeyNotFoundException($"Project for task {taskId} not found.");
        }

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == project.WorkspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, project.WorkspaceId);
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
                .AnyAsync(wm => wm.Workspace.Id == project.WorkspaceId && wm.UserId == request.AssigneeId);

            if (!isAssigneeInWorkspace)
            {
                _logger.LogWarning("Assignee user {AssigneeId} is not a member of workspace {WorkspaceId}", request.AssigneeId, project.WorkspaceId);
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

        return new TaskResponseDto
        {
            Id = task.Id,
            ProjectId = task.ProjectId,
            Title = task.Title,
            Description = task.Description,
            Status = task.Status,
            Priority = task.Priority,
            AssigneeId = task.AssigneeId,
            AssigneeName = assigneeName,
            CreatedBy = task.CreatedBy,
            CreatedByName = task.Creator.Name,
            DueDate = task.DueDate,
            CreatedAt = task.CreatedAt,
            UpdatedAt = task.UpdatedAt
        };
    }

    public async Task DeleteTaskAsync(string userId, int taskId)
    {
        var task = await _context.Tasks.FirstOrDefaultAsync(t => t.Id == taskId);
        if (task == null)
        {
            _logger.LogWarning("Task with ID {TaskId} not found", taskId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found.");
        }

        var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == task.ProjectId);
        if (project == null)
        {
            _logger.LogWarning("Project with ID {ProjectId} not found for task {TaskId}", task.ProjectId, taskId);
            throw new KeyNotFoundException($"Project for task {taskId} not found.");
        }

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == project.WorkspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, project.WorkspaceId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found for user {userId}");
        }

        bool isOwner = workspaceMember.Role == WorkspaceRoles.Owner.ToString();
        bool isCreator = task.CreatedBy == userId;

        if (!isOwner && !isCreator)
        {
            _logger.LogWarning("User {UserId} is not authorized to delete task {TaskId}", userId, taskId);
            throw new ForbiddenException($"User {userId} is not authorized to delete task {taskId}.");
        }

        _context.Tasks.Remove(task);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Task {TaskId} deleted successfully by user {UserId}", taskId, userId);

        var actor = await _userManager.FindByIdAsync(userId);
        await _activityLogger.LogAsync(
            project.WorkspaceId,
            userId,
            actor?.Name ?? userId,
            ActivityEventType.TaskDeleted,
            projectId: task.ProjectId,
            taskId: task.Id,
            metadata: new { task.Title });
    }

    public async Task<TaskResponseDto> UpdateTaskStatusAsync(string userId, int taskId, UpdateTaskStatusDto request)
    {
        var task = await _context.Tasks
            .Include(t => t.Creator)
            .Include(t => t.Assignee)
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null)
        {
            _logger.LogWarning("Task with ID {TaskId} not found", taskId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found.");
        }

        var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == task.ProjectId);
        if (project == null)
        {
            _logger.LogWarning("Project with ID {ProjectId} not found for task {TaskId}", task.ProjectId, taskId);
            throw new KeyNotFoundException($"Project for task {taskId} not found.");
        }

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == project.WorkspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, project.WorkspaceId);
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
            project.WorkspaceId,
            userId,
            actor?.Name ?? userId,
            ActivityEventType.TaskStatusChanged,
            projectId: task.ProjectId,
            taskId: task.Id,
            metadata: new { task.Title, OldStatus = oldStatus, NewStatus = task.Status });

        return new TaskResponseDto
        {
            Id = task.Id,
            ProjectId = task.ProjectId,
            Title = task.Title,
            Description = task.Description,
            Status = task.Status,
            Priority = task.Priority,
            AssigneeId = task.AssigneeId,
            AssigneeName = task.Assignee?.Name,
            CreatedBy = task.CreatedBy,
            CreatedByName = task.Creator.Name,
            DueDate = task.DueDate,
            CreatedAt = task.CreatedAt,
            UpdatedAt = task.UpdatedAt
        };
    }

    public async Task<TaskResponseDto> UpdateTaskAssigneeAsync(string userId, int taskId, UpdateTaskAssigneeDto request)
    {
        var task = await _context.Tasks
            .Include(t => t.Creator)
            .Include(t => t.Assignee)
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null)
        {
            _logger.LogWarning("Task with ID {TaskId} not found", taskId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found.");
        }

        var project = await _context.Projects.FirstOrDefaultAsync(p => p.Id == task.ProjectId);
        if (project == null)
        {
            _logger.LogWarning("Project with ID {ProjectId} not found for task {TaskId}", task.ProjectId, taskId);
            throw new KeyNotFoundException($"Project for task {taskId} not found.");
        }

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == project.WorkspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, project.WorkspaceId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found for user {userId}");
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

        task.AssigneeId = string.IsNullOrWhiteSpace(request.AssigneeId) ? null : request.AssigneeId;
        task.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        _logger.LogInformation("Task {TaskId} assignee updated to '{AssigneeId}'", taskId, task.AssigneeId);

        var assignActor = await _userManager.FindByIdAsync(userId);
        await _activityLogger.LogAsync(
            project.WorkspaceId,
            userId,
            assignActor?.Name ?? userId,
            ActivityEventType.TaskAssigned,
            projectId: task.ProjectId,
            taskId: task.Id,
            metadata: new { task.Title, AssigneeId = task.AssigneeId, AssigneeName = assigneeName });

        return new TaskResponseDto
        {
            Id = task.Id,
            ProjectId = task.ProjectId,
            Title = task.Title,
            Description = task.Description,
            Status = task.Status,
            Priority = task.Priority,
            AssigneeId = task.AssigneeId,
            AssigneeName = assigneeName,
            CreatedBy = task.CreatedBy,
            CreatedByName = task.Creator.Name,
            DueDate = task.DueDate,
            CreatedAt = task.CreatedAt,
            UpdatedAt = task.UpdatedAt
        };
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
                UpdatedAt = t.UpdatedAt
            })
            .ToListAsync();

        return tasks;
    }
}

