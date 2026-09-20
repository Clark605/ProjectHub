using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.CommentDtos;
using ProjectHub.Api.Exceptions;
using ProjectHub.Api.Hubs;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services.Interfaces;
using Task = System.Threading.Tasks.Task;
using TaskEntity = ProjectHub.Api.Models.Task;

namespace ProjectHub.Api.Services;

public class CommentService : ICommentService
{
    private readonly AppDbContext _context;
    private readonly IActivityLogger _activityLogger;
    private readonly IHubContext<WorkspaceHub> _hubContext;
    private readonly ILogger<CommentService> _logger;

    public CommentService(
        AppDbContext context,
        IActivityLogger activityLogger,
        IHubContext<WorkspaceHub> hubContext,
        ILogger<CommentService> logger)
    {
        _context = context;
        _activityLogger = activityLogger;
        _hubContext = hubContext;
        _logger = logger;
    }

    public async Task<IEnumerable<CommentResponseDto>> GetCommentsByTaskAsync(string userId, int taskId)
    {
        var task = await _context.Tasks
            .Include(t => t.Project)
            .FirstOrDefaultAsync(t => t.Id == taskId);

        if (task == null)
        {
            _logger.LogWarning("Task with ID {TaskId} not found", taskId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found.");
        }

        var isMember = await _context.WorkspaceMembers
            .AnyAsync(wm => wm.UserId == userId && wm.Workspace.Id == task.Project.WorkspaceId);

        if (!isMember)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, task.Project.WorkspaceId);
            throw new KeyNotFoundException($"Task with ID {taskId} not found for user {userId}");
        }

        var comments = await _context.Comments
            .Include(c => c.Author)
            .Where(c => c.TaskId == taskId)
            .OrderBy(c => c.CreatedAt)
            .Select(c => new CommentResponseDto
            {
                Id = c.Id,
                TaskId = c.TaskId,
                AuthorId = c.AuthorId,
                AuthorName = c.Author.Name,
                Content = c.Content,
                CreatedAt = c.CreatedAt,
                UpdatedAt = c.UpdatedAt
            })
            .ToListAsync();

        return comments;
    }

    public async Task<CommentResponseDto> CreateCommentAsync(string userId, int taskId, CreateCommentRequestDto request)
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

        var author = await _context.Users.FirstOrDefaultAsync(u => u.Id == userId);
        if (author == null)
        {
            _logger.LogWarning("User {UserId} not found", userId);
            throw new KeyNotFoundException($"User {userId} not found.");
        }

        var comment = new Comment
        {
            TaskId = taskId,
            AuthorId = userId,
            Content = request.Content.Trim(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.Comments.Add(comment);
        await _context.SaveChangesAsync();

        var responseDto = new CommentResponseDto
        {
            Id = comment.Id,
            TaskId = comment.TaskId,
            AuthorId = comment.AuthorId,
            AuthorName = author.Name,
            Content = comment.Content,
            CreatedAt = comment.CreatedAt,
            UpdatedAt = comment.UpdatedAt
        };

        await _activityLogger.LogAsync(
            task.Project.WorkspaceId,
            userId,
            author.Name,
            ActivityEventType.TaskUpdated,
            projectId: task.ProjectId,
            taskId: task.Id,
            metadata: new { CommentId = comment.Id, Action = "CommentAdded" });

        await _hubContext.Clients.Group($"workspace-{task.Project.WorkspaceId}")
            .SendAsync("CommentAdded", responseDto);

        return responseDto;
    }

    public async Task<CommentResponseDto> UpdateCommentAsync(string userId, int commentId, UpdateCommentRequestDto request)
    {
        var comment = await _context.Comments
            .Include(c => c.Author)
            .Include(c => c.Task)
                .ThenInclude(t => t.Project)
            .FirstOrDefaultAsync(c => c.Id == commentId);

        if (comment == null)
        {
            _logger.LogWarning("Comment with ID {CommentId} not found", commentId);
            throw new KeyNotFoundException($"Comment with ID {commentId} not found.");
        }

        var isMember = await _context.WorkspaceMembers
            .AnyAsync(wm => wm.UserId == userId && wm.Workspace.Id == comment.Task.Project.WorkspaceId);

        if (!isMember)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, comment.Task.Project.WorkspaceId);
            throw new KeyNotFoundException($"Comment with ID {commentId} not found for user {userId}");
        }

        if (comment.AuthorId != userId)
        {
            _logger.LogWarning("User {UserId} is not authorized to edit comment {CommentId}", userId, commentId);
            throw new ForbiddenException("You are not authorized to edit this comment.");
        }

        comment.Content = request.Content.Trim();
        comment.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();

        return new CommentResponseDto
        {
            Id = comment.Id,
            TaskId = comment.TaskId,
            AuthorId = comment.AuthorId,
            AuthorName = comment.Author.Name,
            Content = comment.Content,
            CreatedAt = comment.CreatedAt,
            UpdatedAt = comment.UpdatedAt
        };
    }

    public async Task DeleteCommentAsync(string userId, int commentId)
    {
        var comment = await _context.Comments
            .Include(c => c.Task)
                .ThenInclude(t => t.Project)
            .FirstOrDefaultAsync(c => c.Id == commentId);

        if (comment == null)
        {
            _logger.LogWarning("Comment with ID {CommentId} not found", commentId);
            throw new KeyNotFoundException($"Comment with ID {commentId} not found.");
        }

        var workspaceMember = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == comment.Task.Project.WorkspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, comment.Task.Project.WorkspaceId);
            throw new KeyNotFoundException($"Comment with ID {commentId} not found for user {userId}");
        }

        bool isOwner = workspaceMember.Role == WorkspaceRoles.Owner.ToString();
        bool isAuthor = comment.AuthorId == userId;

        if (!isAuthor && !isOwner)
        {
            _logger.LogWarning("User {UserId} is not authorized to delete comment {CommentId}", userId, commentId);
            throw new ForbiddenException("You are not authorized to delete this comment.");
        }

        var workspaceId = comment.Task.Project.WorkspaceId;
        var taskId = comment.TaskId;

        _context.Comments.Remove(comment);
        await _context.SaveChangesAsync();

        await _hubContext.Clients.Group($"workspace-{workspaceId}")
            .SendAsync("CommentDeleted", new { TaskId = taskId, CommentId = commentId });
    }
}
