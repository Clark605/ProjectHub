using System;

namespace ProjectHub.Api.Models;

public class Project
{
    public int Id { get; set; }
    public int WorkspaceId { get; set; }
    public WorkSpace Workspace { get; set; } = null!;
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Status { get; set; } = ProjectStatus.Planning.ToString();
    public DateTime? DueDate { get; set; }
    public string CreatedBy { get; set; } = string.Empty;
    public AppUser Creator { get; set; } = null!;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<Task> Tasks { get; set; } = new List<Task>();
}

