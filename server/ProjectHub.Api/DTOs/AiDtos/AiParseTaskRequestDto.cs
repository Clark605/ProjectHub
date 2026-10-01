namespace ProjectHub.Api.DTOs.AiDtos;

/// <summary>
/// Request DTO for the AI task parsing endpoint.
/// </summary>
public class AiParseTaskRequestDto
{
    /// <summary>
    /// The transcribed speech text to parse into task fields.
    /// </summary>
    public string Text { get; set; } = string.Empty;

    /// <summary>
    /// The target project ID where the task will be created.
    /// </summary>
    public int ProjectId { get; set; }

    /// <summary>
    /// The workspace ID for member context and assignee resolution.
    /// </summary>
    public int WorkspaceId { get; set; }

    /// <summary>
    /// The user's current local time with timezone offset for relative date resolution.
    /// </summary>
    public DateTimeOffset UserLocalTime { get; set; }
}
