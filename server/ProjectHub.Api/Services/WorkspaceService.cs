using System;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Hybrid;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.WorkSpaceDtos;
using ProjectHub.Api.Exceptions;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services.Interfaces;
using Task = System.Threading.Tasks.Task;

namespace ProjectHub.Api.Services;

public class WorkspaceService : IWorkspaceService
{
    private readonly AppDbContext _context;
    private readonly UserManager<AppUser> _userManager;
    private readonly HybridCache _cache;
    private readonly IActivityLogger _activityLogger;
    private readonly ILogger<WorkspaceService> _logger;

    public WorkspaceService(
        AppDbContext context,
        UserManager<AppUser> userManager,
        HybridCache cache,
        IActivityLogger activityLogger,
        ILogger<WorkspaceService> logger)
    {
        _context = context;
        _userManager = userManager;
        _cache = cache;
        _activityLogger = activityLogger;
        _logger = logger;
    }

    // Workspace management methods
    public async Task<WorkspaceResponseDto> CreateWorkspaceAsync(string userId, CreateWorkspaceRequestDto request)
    {
        _logger.LogInformation("Creating workspace for user {UserId} with name {WorkspaceName}", userId, request.Name);
        var workspace = new WorkSpace
        {
            Name = request.Name,
            Description = request.Description,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _context.WorkSpaces.Add(workspace);

        var workspaceMember = new WorkspaceMember
        {
            UserId = userId,
            Workspace = workspace,
            Role = WorkspaceRoles.Owner.ToString(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        _context.WorkspaceMembers.Add(workspaceMember);

        await _context.SaveChangesAsync();
        _logger.LogInformation("Workspace {WorkspaceId} created successfully", workspace.Id);

        var actor = await _userManager.FindByIdAsync(userId);
        await _activityLogger.LogAsync(
            workspace.Id,
            userId,
            actor?.Name ?? userId,
            ActivityEventType.WorkspaceCreated,
            metadata: new { workspace.Name });

        // Invalidate user's workspace list cache
        await _cache.RemoveByTagAsync($"user:{userId}:workspaces");

        return new WorkspaceResponseDto
        {
            Id = workspace.Id,
            Name = workspace.Name,
            Description = workspace.Description,
            Membership = new WorkspaceMembershipDto(workspaceMember.Role, workspaceMember.CreatedAt)
        };
    }

    public async Task<IEnumerable<WorkspaceResponseDto>> GetWorkspacesByUserIdAsync(string userId)
    {
        string cacheKey = $"user:{userId}:workspaces";

        return await _cache.GetOrCreateAsync(
            cacheKey,
            async token => await _context.WorkspaceMembers
                .Where(wm => wm.UserId == userId)
                .Select(wm => new WorkspaceResponseDto
                {
                    Id = wm.Workspace.Id,
                    Name = wm.Workspace.Name,
                    Description = wm.Workspace.Description,
                    Membership = new WorkspaceMembershipDto(wm.Role, wm.CreatedAt)
                })
                .ToListAsync(token),
            tags: [$"user:{userId}:workspaces"]
        );
    }

    public async Task<WorkspaceResponseDto> GetWorkspaceByIdAsync(string userId, int workspaceId)
    {
        string cacheKey = $"workspace:{workspaceId}:user:{userId}:details";

        var workspace = await _cache.GetOrCreateAsync(
            cacheKey,
            async token => await _context.WorkspaceMembers
                .Where(wm => wm.UserId == userId && wm.Workspace.Id == workspaceId)
                .Select(wm => new WorkspaceResponseDto
                {
                    Id = wm.Workspace.Id,
                    Name = wm.Workspace.Name,
                    Description = wm.Workspace.Description,
                    Membership = new WorkspaceMembershipDto(wm.Role, wm.CreatedAt)
                })
                .FirstOrDefaultAsync(token),
            tags: [$"workspace:{workspaceId}", $"user:{userId}:workspaces"]
        );

        if (workspace == null)
        {
            _logger.LogWarning("Workspace with ID {WorkspaceId} not found for user {UserId}", workspaceId, userId);
            throw new KeyNotFoundException($"Workspace with ID {workspaceId} not found for user {userId}");
        }

        return workspace;
    }

    public async Task<WorkspaceResponseDto> UpdateWorkspaceAsync(string userId, int workspaceId, UpdateWorkspaceRequestDto request)
    {
        var workspaceMember = await _context.WorkspaceMembers
            .Include(wm => wm.Workspace)
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == workspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("Workspace with ID {WorkspaceId} not found for user {UserId}", workspaceId, userId);
            throw new KeyNotFoundException($"Workspace with ID {workspaceId} not found for user {userId}");
        }

        if (workspaceMember.Role != WorkspaceRoles.Owner.ToString())
        {
            _logger.LogWarning("User {UserId} is not the owner of workspace {WorkspaceId}", userId, workspaceId);
            throw new ForbiddenException($"User {userId} is not the owner of workspace {workspaceId}");
        }

        workspaceMember.Workspace.Name = request.Name;
        workspaceMember.Workspace.Description = request.Description;
        workspaceMember.Workspace.UpdatedAt = DateTime.UtcNow;

        await _context.SaveChangesAsync();
        _logger.LogInformation("Workspace {WorkspaceId} updated successfully", workspaceId);

        var actor = await _userManager.FindByIdAsync(userId);
        await _activityLogger.LogAsync(
            workspaceId,
            userId,
            actor?.Name ?? userId,
            ActivityEventType.WorkspaceUpdated,
            metadata: new { request.Name });

        // Invalidate workspace details cache and all members' workspace list caches
        await _cache.RemoveByTagAsync($"workspace:{workspaceId}");
        var memberUserIds = await _context.WorkspaceMembers
            .Where(wm => wm.Workspace.Id == workspaceId)
            .Select(wm => wm.UserId)
            .ToListAsync();
        foreach (var memberUserId in memberUserIds)
        {
            await _cache.RemoveByTagAsync($"user:{memberUserId}:workspaces");
        }

        return new WorkspaceResponseDto
        {
            Id = workspaceMember.Workspace.Id,
            Name = workspaceMember.Workspace.Name,
            Description = workspaceMember.Workspace.Description,
            Membership = new WorkspaceMembershipDto(workspaceMember.Role, workspaceMember.CreatedAt)
        };
    }

    public async Task DeleteWorkspaceAsync(string userId, int workspaceId)
    {
        var workspaceMember = await _context.WorkspaceMembers
            .Include(wm => wm.Workspace)
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == workspaceId);

        if (workspaceMember == null)
        {
            _logger.LogWarning("Workspace with ID {WorkspaceId} not found for user {UserId}", workspaceId, userId);
            throw new KeyNotFoundException($"Workspace with ID {workspaceId} not found for user {userId}");
        }

        if (workspaceMember.Role != WorkspaceRoles.Owner.ToString())
        {
            _logger.LogWarning("User {UserId} is not the owner of workspace {WorkspaceId}", userId, workspaceId);
            throw new ForbiddenException($"User {userId} is not the owner of workspace {workspaceId}");
        }

        var workspace = workspaceMember.Workspace;
        var allMembers = await _context.WorkspaceMembers
            .Where(wm => wm.Workspace.Id == workspaceId)
            .ToListAsync();

        var memberUserIds = allMembers.Select(m => m.UserId).ToList();

        _context.WorkspaceMembers.RemoveRange(allMembers);
        _context.WorkSpaces.Remove(workspace);

        await _context.SaveChangesAsync();
        _logger.LogInformation("Workspace {WorkspaceId} deleted successfully", workspaceId);

        // Invalidate all related caches
        await _cache.RemoveByTagAsync($"workspace:{workspaceId}");
        await _cache.RemoveByTagAsync($"workspace:{workspaceId}:members");
        await _cache.RemoveByTagAsync($"workspace:{workspaceId}:projects");
        foreach (var memberUserId in memberUserIds)
        {
            await _cache.RemoveByTagAsync($"user:{memberUserId}:workspaces");
        }
    }

    // Member management methods
    public async Task<IEnumerable<MemberResponseDto>> GetMembersByWorkspaceIdAsync(string userId, int workspaceId)
    {
        var isMember = await _context.WorkspaceMembers
            .AnyAsync(wm => wm.UserId == userId && wm.Workspace.Id == workspaceId);

        if (!isMember)
        {
            _logger.LogWarning("User {UserId} is not a member of workspace {WorkspaceId}", userId, workspaceId);
            throw new KeyNotFoundException($"Workspace with ID {workspaceId} not found for user {userId}");
        }

        string cacheKey = $"workspace:{workspaceId}:members";

        return await _cache.GetOrCreateAsync(
            cacheKey,
            async token => await _context.WorkspaceMembers
                .Where(wm => wm.Workspace.Id == workspaceId)
                .Join(_context.Users,
                    wm => wm.UserId,
                    u => u.Id,
                    (wm, u) => new MemberResponseDto
                    {
                        UserId = u.Id,
                        Name = u.Name,
                        Email = u.Email ?? string.Empty,
                        Role = wm.Role,
                        JoinedAt = wm.CreatedAt
                    })
                .ToListAsync(token),
            tags: [$"workspace:{workspaceId}:members", $"workspace:{workspaceId}"]
        );
    }

    public async Task<MemberResponseDto> AddMemberToWorkspaceAsync(string userId, int workspaceId, AddMemberDto request)
    {
        var ownerMembership = await _context.WorkspaceMembers
            .Include(wm => wm.Workspace)
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == workspaceId);

        if (ownerMembership == null)
        {
            _logger.LogWarning("Workspace with ID {WorkspaceId} not found for user {UserId}", workspaceId, userId);
            throw new KeyNotFoundException($"Workspace with ID {workspaceId} not found for user {userId}");
        }

        if (ownerMembership.Role != WorkspaceRoles.Owner.ToString())
        {
            _logger.LogWarning("User {UserId} is not the owner of workspace {WorkspaceId}", userId, workspaceId);
            throw new ForbiddenException($"User {userId} is not the owner of workspace {workspaceId}");
        }

        var targetUser = await _userManager.FindByEmailAsync(request.Email.Trim());
        if (targetUser == null)
        {
            _logger.LogWarning("Target user with email {Email} not found.", request.Email);
            throw new KeyNotFoundException($"User with email '{request.Email}' was not found.");
        }

        var isAlreadyMember = await _context.WorkspaceMembers
            .AnyAsync(wm => wm.Workspace.Id == workspaceId && wm.UserId == targetUser.Id);

        if (isAlreadyMember)
        {
            _logger.LogWarning("User {TargetUserId} is already a member of workspace {WorkspaceId}", targetUser.Id, workspaceId);
            throw new ArgumentException($"User with email '{request.Email}' is already a member of this workspace.");
        }

        var newMember = new WorkspaceMember
        {
            UserId = targetUser.Id,
            Workspace = ownerMembership.Workspace,
            Role = WorkspaceRoles.Member.ToString(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _context.WorkspaceMembers.Add(newMember);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Added user {TargetUserId} as Member to workspace {WorkspaceId}", targetUser.Id, workspaceId);

        var actor = await _userManager.FindByIdAsync(userId);
        await _activityLogger.LogAsync(
            workspaceId,
            userId,
            actor?.Name ?? userId,
            ActivityEventType.MemberAdded,
            metadata: new { TargetUserId = targetUser.Id, TargetName = targetUser.Name, Role = newMember.Role });

        // Invalidate members cache and target user's workspace list
        await _cache.RemoveByTagAsync($"workspace:{workspaceId}:members");
        await _cache.RemoveByTagAsync($"user:{targetUser.Id}:workspaces");

        return new MemberResponseDto
        {
            UserId = targetUser.Id,
            Name = targetUser.Name,
            Email = targetUser.Email ?? string.Empty,
            Role = newMember.Role,
            JoinedAt = newMember.CreatedAt
        };
    }

    public async Task RemoveMemberFromWorkspaceAsync(string userId, int workspaceId, string memberId)
    {
        var ownerMembership = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.UserId == userId && wm.Workspace.Id == workspaceId);

        if (ownerMembership == null)
        {
            _logger.LogWarning("Workspace with ID {WorkspaceId} not found for user {UserId}", workspaceId, userId);
            throw new KeyNotFoundException($"Workspace with ID {workspaceId} not found for user {userId}");
        }

        if (ownerMembership.Role != WorkspaceRoles.Owner.ToString())
        {
            _logger.LogWarning("User {UserId} is not the owner of workspace {WorkspaceId}", userId, workspaceId);
            throw new ForbiddenException($"User {userId} is not the owner of workspace {workspaceId}");
        }

        if (userId == memberId)
        {
            _logger.LogWarning("Owner {UserId} attempted to remove self from workspace {WorkspaceId}", userId, workspaceId);
            throw new ArgumentException("Workspace owner cannot be removed from the workspace.");
        }

        var targetMembership = await _context.WorkspaceMembers
            .FirstOrDefaultAsync(wm => wm.Workspace.Id == workspaceId && wm.UserId == memberId);

        if (targetMembership == null)
        {
            _logger.LogWarning("Member with ID {MemberId} not found in workspace {WorkspaceId}", memberId, workspaceId);
            throw new KeyNotFoundException($"Member with user ID '{memberId}' was not found in workspace {workspaceId}.");
        }

        var workspaceProjectIds = await _context.Projects
            .Where(p => p.WorkspaceId == workspaceId)
            .Select(p => p.Id)
            .ToListAsync();

        if (workspaceProjectIds.Count != 0)
        {
            var assignedTasks = await _context.Tasks
                .Where(t => workspaceProjectIds.Contains(t.ProjectId) && t.AssigneeId == memberId)
                .ToListAsync();

            foreach (var task in assignedTasks)
            {
                task.AssigneeId = null;
                task.UpdatedAt = DateTime.UtcNow;
            }
        }

        _context.WorkspaceMembers.Remove(targetMembership);
        await _context.SaveChangesAsync();

        _logger.LogInformation("Removed member {MemberId} from workspace {WorkspaceId} and unassigned their tasks", memberId, workspaceId);

        var actor = await _userManager.FindByIdAsync(userId);
        await _activityLogger.LogAsync(
            workspaceId,
            userId,
            actor?.Name ?? userId,
            ActivityEventType.MemberRemoved,
            metadata: new { TargetUserId = memberId });

        // Invalidate members cache and removed member's workspace list
        await _cache.RemoveByTagAsync($"workspace:{workspaceId}:members");
        await _cache.RemoveByTagAsync($"user:{memberId}:workspaces");
    }
}

