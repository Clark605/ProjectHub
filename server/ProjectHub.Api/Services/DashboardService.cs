using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.DashboardDtos;
using ProjectHub.Api.DTOs.TagDtos;
using ProjectHub.Api.DTOs.TaskDtos;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services.Interfaces;

namespace ProjectHub.Api.Services;

public class DashboardService : IDashboardService
{
    private readonly AppDbContext _context;
    private readonly IActivityLogger _activityLogger;
    private readonly ILogger<DashboardService> _logger;

    public DashboardService(
        AppDbContext context,
        IActivityLogger activityLogger,
        ILogger<DashboardService> logger)
    {
        _context = context;
        _activityLogger = activityLogger;
        _logger = logger;
    }

    public async Task<WorkspaceDashboardDto> GetWorkspaceDashboardAsync(string userId, int workspaceId)
    {
        var isMember = await _context.WorkspaceMembers
            .AnyAsync(wm => wm.UserId == userId && wm.Workspace.Id == workspaceId);

        if (!isMember)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, workspaceId);
            throw new KeyNotFoundException($"Workspace with ID {workspaceId} not found for user {userId}");
        }

        var now = DateTime.UtcNow;
        var todayUtc = now.Date;
        var diff = (7 + ((int)now.DayOfWeek - (int)DayOfWeek.Monday)) % 7;
        var startOfWeek = todayUtc.AddDays(-1 * diff);
        var endOfWeek = startOfWeek.AddDays(7);

        var activeProjectsCount = await _context.Projects
            .CountAsync(p => p.WorkspaceId == workspaceId && p.Status != ProjectStatus.Archived.ToString());

        var taskStats = await _context.Tasks
            .Where(t => t.Project.WorkspaceId == workspaceId)
            .GroupBy(t => 1)
            .Select(g => new
            {
                InProgress = g.Count(t => t.Status == TaskItemStatus.InProgress),
                Urgent = g.Count(t => t.Priority == TaskItemPriority.Urgent && t.Status != TaskItemStatus.Done),
                Completed = g.Count(t => t.Status == TaskItemStatus.Done),
                Overdue = g.Count(t => t.Status != TaskItemStatus.Done && t.DueDate != null && t.DueDate < todayUtc),
                DueThisWeek = g.Count(t => t.Status != TaskItemStatus.Done && t.DueDate != null && t.DueDate >= startOfWeek && t.DueDate < endOfWeek)
            })
            .FirstOrDefaultAsync();

        var focusTasks = await _context.Tasks
            .Where(t => t.Project.WorkspaceId == workspaceId && t.AssigneeId == userId && t.Status != TaskItemStatus.Done)
            .OrderByDescending(t => t.Priority)
            .ThenBy(t => t.DueDate == null ? 1 : 0)
            .ThenBy(t => t.DueDate)
            .Take(5)
            .Select(t => new TaskResponseDto
            {
                Id = t.Id,
                ProjectId = t.ProjectId,
                ProjectName = t.Project.Name,
                Title = t.Title,
                Description = t.Description,
                Status = t.Status.ToString(),
                Priority = t.Priority.ToString(),
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
                    Name = tt.Tag.Name,
                    Color = tt.Tag.Color,
                    WorkspaceId = tt.Tag.WorkspaceId,
                    ProjectId = tt.Tag.ProjectId
                }).ToList()
            })
            .ToListAsync();

        var recentActivities = (await _activityLogger.GetWorkspaceActivitiesAsync(workspaceId, limit: 15)).ToList();

        return new WorkspaceDashboardDto
        {
            ActiveProjectsCount = activeProjectsCount,
            InProgressTasksCount = taskStats?.InProgress ?? 0,
            UrgentTasksCount = taskStats?.Urgent ?? 0,
            CompletedTasksCount = taskStats?.Completed ?? 0,
            OverdueTasksCount = taskStats?.Overdue ?? 0,
            DueThisWeekTasksCount = taskStats?.DueThisWeek ?? 0,
            FocusTasks = focusTasks,
            RecentActivities = recentActivities
        };
    }
}
