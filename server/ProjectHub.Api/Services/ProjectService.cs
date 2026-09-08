using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Hybrid;
using Microsoft.Extensions.Logging;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.ProjectDtos;
using ProjectHub.Api.Exceptions;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services.Interfaces;
using Task = System.Threading.Tasks.Task;

namespace ProjectHub.Api.Services;

public class ProjectService : IProjectService
{
    private readonly AppDbContext _context;
    private readonly UserManager<AppUser> _userManager;
    private readonly HybridCache _cache;
    private readonly IActivityLogger _activityLogger;
    private readonly ILogger<ProjectService> _logger;

    public ProjectService(
        AppDbContext context,
        UserManager<AppUser> userManager,
        HybridCache cache,
        IActivityLogger activityLogger,
        ILogger<ProjectService> logger)
    {
        _context = context;
        _userManager = userManager;
        _cache = cache;
        _activityLogger = activityLogger;
        _logger = logger;
    }

    public async Task<ProjectResponseDto> CreateProjectAsync(string userId, int workspaceId, CreateProjectRequestDto request)
    {
        _logger.LogInformation("User {UserId} creating project '{ProjectName}' in workspace {WorkspaceId}", userId, request.Name, workspaceId);

        var isWorkspaceMember = await _context.WorkspaceMembers
            .AnyAsync(wm => wm.UserId == userId && wm.Workspace.Id == workspaceId);

        if (!isWorkspaceMember)
        {
            _logger.LogWarning("Workspace {WorkspaceId} not found or user {UserId} is not a member", workspaceId, userId);
            throw new KeyNotFoundException($"Workspace with ID {workspaceId} not found for user {userId}");
        }

        var creator = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
        if (creator == null)
        {
            _logger.LogWarning("User with ID {UserId} not found", userId);
            throw new KeyNotFoundException($"User with ID {userId} not found");
        }

        var project = new Project
        {
            WorkspaceId = workspaceId,
            Name = request.Name,
            Description = request.Description,
            Status = ProjectStatus.Planning.ToString(),
            DueDate = request.DueDate,
            CreatedBy = userId,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Projects.Add(project);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Project {ProjectId} created successfully by user {UserId}", project.Id, userId);

        await _activityLogger.LogAsync(
            workspaceId,
            userId,
            creator.Name,
            ActivityEventType.ProjectCreated,
            projectId: project.Id,
            metadata: new { project.Name, project.Status });

        // Invalidate workspace projects cache
        await _cache.RemoveByTagAsync($"workspace:{workspaceId}:projects");

        return new ProjectResponseDto
        {
            Id = project.Id,
            WorkspaceId = project.WorkspaceId,
            Name = project.Name,
            Description = project.Description,
            Status = project.Status,
            DueDate = project.DueDate,
            CreatedBy = project.CreatedBy,
            CreatedByName = creator.Name,
            CreatedAt = project.CreatedAt,
            UpdatedAt = project.UpdatedAt
        };
    }

    public async Task<IEnumerable<ProjectResponseDto>> GetProjectsByWorkspaceAsync(string userId, int workspaceId, string? status)
    {
        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == workspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("Workspace {WorkspaceId} not found for user {UserId}", workspaceId, userId);
            throw new KeyNotFoundException($"Workspace with ID {workspaceId} not found for user {userId}");
        }

        string normalizedStatus = status?.Trim().ToLower() ?? "all";
        string cacheKey = $"workspace:{workspaceId}:projects:{normalizedStatus}";

        return await _cache.GetOrCreateAsync(
            cacheKey,
            async token =>
            {
                var query = _context.Projects
                    .Where(p => p.WorkspaceId == workspaceId);

                if (!string.IsNullOrWhiteSpace(status))
                {
                    query = query.Where(p => p.Status.ToLower() == status.Trim().ToLower());
                }
                else
                {
                    query = query.Where(p => p.Status != ProjectStatus.Archived.ToString());
                }

                return await query
                    .Select(p => new ProjectResponseDto
                    {
                        Id = p.Id,
                        WorkspaceId = p.WorkspaceId,
                        Name = p.Name,
                        Description = p.Description,
                        Status = p.Status,
                        DueDate = p.DueDate,
                        CreatedBy = p.CreatedBy,
                        CreatedByName = p.Creator.Name,
                        CreatedAt = p.CreatedAt,
                        UpdatedAt = p.UpdatedAt
                    })
                    .ToListAsync(token);
            },
            tags: [$"workspace:{workspaceId}:projects", $"workspace:{workspaceId}"]
        );
    }

    public async Task<ProjectResponseDto> GetProjectByIdAsync(string userId, int projectId)
    {
        var projectInfo = await _context.Projects
            .Where(p => p.Id == projectId)
            .Select(p => new { p.Id, p.WorkspaceId })
            .FirstOrDefaultAsync();

        if (projectInfo == null)
        {
            _logger.LogWarning("Project with ID {ProjectId} not found", projectId);
            throw new KeyNotFoundException($"Project with ID {projectId} not found.");
        }

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == projectInfo.WorkspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, projectInfo.WorkspaceId);
            throw new KeyNotFoundException($"Project with ID {projectId} not found for user {userId}");
        }

        string cacheKey = $"project:{projectId}:details";

        var project = await _cache.GetOrCreateAsync(
            cacheKey,
            async token => await _context.Projects
                .Where(p => p.Id == projectId)
                .Select(p => new ProjectResponseDto
                {
                    Id = p.Id,
                    WorkspaceId = p.WorkspaceId,
                    Name = p.Name,
                    Description = p.Description,
                    Status = p.Status,
                    DueDate = p.DueDate,
                    CreatedBy = p.CreatedBy,
                    CreatedByName = p.Creator.Name,
                    CreatedAt = p.CreatedAt,
                    UpdatedAt = p.UpdatedAt
                })
                .FirstOrDefaultAsync(token),
            tags: [$"project:{projectId}", $"workspace:{projectInfo.WorkspaceId}"]
        );

        if (project == null)
        {
            _logger.LogWarning("Project with ID {ProjectId} not found", projectId);
            throw new KeyNotFoundException($"Project with ID {projectId} not found.");
        }

        return project;
    }

    public async Task<ProjectResponseDto> UpdateProjectAsync(string userId, int projectId, UpdateProjectRequestDto request)
    {
        var project = await _context.Projects
            .Include(p => p.Creator)
            .FirstOrDefaultAsync(p => p.Id == projectId);

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

        bool isOwner = workspaceMember.Role == WorkspaceRoles.Owner.ToString();
        bool isCreator = project.CreatedBy == userId;

        if (!isOwner && !isCreator)
        {
            _logger.LogWarning("User {UserId} does not have permission to update project {ProjectId}", userId, projectId);
            throw new ForbiddenException($"User {userId} does not have permission to update project {projectId}.");
        }

        var oldStatus = project.Status;
        project.Name = request.Name;
        project.Description = request.Description;
        project.Status = request.Status;
        project.DueDate = request.DueDate;
        project.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        _logger.LogInformation("Project {ProjectId} updated successfully", projectId);

        var eventType = request.Status == ProjectStatus.Archived.ToString()
            ? ActivityEventType.ProjectArchived
            : ActivityEventType.ProjectStatusChanged;

        var actor = await _userManager.FindByIdAsync(userId);
        await _activityLogger.LogAsync(
            project.WorkspaceId,
            userId,
            actor?.Name ?? userId,
            eventType,
            projectId: project.Id,
            metadata: new { project.Name, OldStatus = oldStatus, NewStatus = request.Status });

        // Invalidate project details cache and workspace projects list cache
        await _cache.RemoveByTagAsync($"project:{projectId}");
        await _cache.RemoveByTagAsync($"workspace:{project.WorkspaceId}:projects");

        return new ProjectResponseDto
        {
            Id = project.Id,
            WorkspaceId = project.WorkspaceId,
            Name = project.Name,
            Description = project.Description,
            Status = project.Status,
            DueDate = project.DueDate,
            CreatedBy = project.CreatedBy,
            CreatedByName = project.Creator?.Name ?? string.Empty,
            CreatedAt = project.CreatedAt,
            UpdatedAt = project.UpdatedAt
        };
    }

    public async Task DeleteProjectAsync(string userId, int projectId)
    {
        var project = await _context.Projects
            .FirstOrDefaultAsync(p => p.Id == projectId);

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

        bool isOwner = workspaceMember.Role == WorkspaceRoles.Owner.ToString();
        bool isCreator = project.CreatedBy == userId;

        if (!isOwner && !isCreator)
        {
            _logger.LogWarning("User {UserId} is not authorized to delete project {ProjectId}", userId, projectId);
            throw new ForbiddenException($"User {userId} is not authorized to delete project {projectId}.");
        }

        int workspaceId = project.WorkspaceId;
        _context.Projects.Remove(project);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Project {ProjectId} deleted successfully by user {UserId}", projectId, userId);

        // Invalidate project details cache and workspace projects list cache
        await _cache.RemoveByTagAsync($"project:{projectId}");
        await _cache.RemoveByTagAsync($"workspace:{workspaceId}:projects");
    }
}
