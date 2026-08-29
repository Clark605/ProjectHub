using System;

namespace ProjectHub.Api.Models;

public class WorkspaceMember
{
    public int Id { get; set; }
    public string UserId { get; set; } = string.Empty;
    public WorkSpace Workspace { get; set; } = null!;
    public string Role { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}
