namespace ProjectHub.Api.Models;

public class ActivityEvent
{
    public int Id { get; set; }
    public int WorkspaceId { get; set; }
    public WorkSpace Workspace { get; set; } = null!;
    public int? ProjectId { get; set; }
    public Project? Project { get; set; }
    public int? TaskId { get; set; }
    public string ActorId { get; set; } = string.Empty;
    public string ActorName { get; set; } = string.Empty;
    public ActivityEventType EventType { get; set; }
    public string? Metadata { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
