using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Collections.Concurrent;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using StackExchange.Redis;

namespace ProjectHub.Api.Hubs;

public class PresenceChangedDto
{
    public int WorkspaceId { get; set; }
    public List<string> OnlineUserIds { get; set; } = [];
}

[Authorize]
public class WorkspaceHub : Hub
{
    private readonly IConnectionMultiplexer? _redis;
    private readonly IDatabase? _db;

    private static readonly ConcurrentDictionary<int, ConcurrentDictionary<string, string>> s_memWsConnections = new();
    private static readonly ConcurrentDictionary<string, ConcurrentBag<int>> s_memConnWorkspaces = new();

    public WorkspaceHub(IConnectionMultiplexer? redis = null)
    {
        _redis = redis;
        _db = redis?.GetDatabase();
    }

    public async Task JoinWorkspace(int workspaceId)
    {
        var userId = Context.UserIdentifier ?? Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userId))
        {
            return;
        }

        var connectionId = Context.ConnectionId;
        var groupName = $"workspace-{workspaceId}";

        await Groups.AddToGroupAsync(connectionId, groupName);

        if (_db != null)
        {
            await _db.SetAddAsync($"conn:{connectionId}:workspaces", workspaceId);
            await _db.HashSetAsync($"workspace:{workspaceId}:connections", connectionId, userId);
            await _db.SetAddAsync($"workspace:{workspaceId}:online_users", userId);
        }
        else
        {
            var wsMap = s_memWsConnections.GetOrAdd(workspaceId, _ => new ConcurrentDictionary<string, string>());
            wsMap[connectionId] = userId;
            var connList = s_memConnWorkspaces.GetOrAdd(connectionId, _ => new ConcurrentBag<int>());
            connList.Add(workspaceId);
        }

        var onlineMembers = await GetOnlineUsersAsync(workspaceId);
        await Clients.Group(groupName).SendAsync("PresenceChanged", new PresenceChangedDto
        {
            WorkspaceId = workspaceId,
            OnlineUserIds = onlineMembers
        });
    }

    public async Task LeaveWorkspace(int workspaceId)
    {
        var userId = Context.UserIdentifier ?? Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var connectionId = Context.ConnectionId;
        var groupName = $"workspace-{workspaceId}";

        await Groups.RemoveFromGroupAsync(connectionId, groupName);
        if (_db != null)
        {
            await _db.SetRemoveAsync($"conn:{connectionId}:workspaces", workspaceId);
            await _db.HashDeleteAsync($"workspace:{workspaceId}:connections", connectionId);

            if (!string.IsNullOrEmpty(userId))
            {
                var remainingConnections = await _db.HashGetAllAsync($"workspace:{workspaceId}:connections");
                var hasOtherConnections = remainingConnections.Any(e => e.Value == userId);
                if (!hasOtherConnections)
                {
                    await _db.SetRemoveAsync($"workspace:{workspaceId}:online_users", userId);
                }
            }
        }
        else
        {
            if (s_memWsConnections.TryGetValue(workspaceId, out var wsMap))
            {
                wsMap.TryRemove(connectionId, out _);
            }
        }

        var onlineMembers = await GetOnlineUsersAsync(workspaceId);
        await Clients.Group(groupName).SendAsync("PresenceChanged", new PresenceChangedDto
        {
            WorkspaceId = workspaceId,
            OnlineUserIds = onlineMembers
        });
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = Context.UserIdentifier ?? Context.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        var connectionId = Context.ConnectionId;

        if (_db != null)
        {
            var workspaces = await _db.SetMembersAsync($"conn:{connectionId}:workspaces");
            foreach (var wsVal in workspaces)
            {
                if (int.TryParse((string?)wsVal, out var workspaceId))
                {
                    await _db.HashDeleteAsync($"workspace:{workspaceId}:connections", connectionId);

                    if (!string.IsNullOrEmpty(userId))
                    {
                        var remainingConnections = await _db.HashGetAllAsync($"workspace:{workspaceId}:connections");
                        var hasOtherConnections = remainingConnections.Any(e => e.Value == userId);
                        if (!hasOtherConnections)
                        {
                            await _db.SetRemoveAsync($"workspace:{workspaceId}:online_users", userId);
                        }
                    }

                    var onlineMembers = await GetOnlineUsersAsync(workspaceId);
                    await Clients.Group($"workspace-{workspaceId}").SendAsync("PresenceChanged", new PresenceChangedDto
                    {
                        WorkspaceId = workspaceId,
                        OnlineUserIds = onlineMembers
                    });
                }
            }

            await _db.KeyDeleteAsync($"conn:{connectionId}:workspaces");
        }
        else
        {
            if (s_memConnWorkspaces.TryRemove(connectionId, out var workspaces))
            {
                foreach (var workspaceId in workspaces.Distinct())
                {
                    if (s_memWsConnections.TryGetValue(workspaceId, out var wsMap))
                    {
                        wsMap.TryRemove(connectionId, out _);
                    }

                    var onlineMembers = await GetOnlineUsersAsync(workspaceId);
                    await Clients.Group($"workspace-{workspaceId}").SendAsync("PresenceChanged", new PresenceChangedDto
                    {
                        WorkspaceId = workspaceId,
                        OnlineUserIds = onlineMembers
                    });
                }
            }
        }

        await base.OnDisconnectedAsync(exception);
    }

    private async Task<List<string>> GetOnlineUsersAsync(int workspaceId)
    {
        if (_db != null)
        {
            var members = await _db.SetMembersAsync($"workspace:{workspaceId}:online_users");
            return members.Select(m => (string)m!).Where(s => !string.IsNullOrEmpty(s)).ToList();
        }

        if (s_memWsConnections.TryGetValue(workspaceId, out var wsMap))
        {
            return wsMap.Values.Distinct().ToList();
        }

        return [];
    }
}
