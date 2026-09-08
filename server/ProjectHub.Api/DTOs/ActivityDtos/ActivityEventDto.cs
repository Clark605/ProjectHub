namespace ProjectHub.Api.DTOs.ActivityDtos;

public class ActivityEventDto
{
    public int Id { get; set; }
    public int WorkspaceId { get; set; }
    public int? ProjectId { get; set; }
    public int? TaskId { get; set; }
    public string ActorId { get; set; } = string.Empty;
    public string ActorName { get; set; } = string.Empty;
    public string EventType { get; set; } = string.Empty;
    public string? Metadata { get; set; }
    public DateTime CreatedAt { get; set; }
}
