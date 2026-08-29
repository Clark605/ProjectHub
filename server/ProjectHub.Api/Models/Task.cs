using System;

namespace ProjectHub.Api.Models;

public class Task
{
    public int Id { get; set; }
    public int ProjectId { get; set; }
    public Project Project { get; set; } = null!;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Status { get; set; } = TaskItemStatus.Backlog.ToString();
    public string Priority { get; set; } = TaskItemPriority.Medium.ToString();
    public string? AssigneeId { get; set; }
    public AppUser? Assignee { get; set; }
    public string CreatedBy { get; set; } = string.Empty;
    public AppUser Creator { get; set; } = null!;
    public DateTime? DueDate { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

