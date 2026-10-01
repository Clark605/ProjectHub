namespace ProjectHub.Api.DTOs.AiDtos;

/// <summary>
/// Response DTO representing a parsed task draft from AI text analysis.
/// </summary>
public class AiParsedTaskDraftDto
{
    /// <summary>
    /// Concise action-oriented task title (max 200 chars).
    /// </summary>
    public string Title { get; set; } = string.Empty;

    /// <summary>
    /// Enhanced structured description with summary line and bullet points.
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// Task priority: "Low", "Medium", "High", or "Urgent". Defaults to "Medium".
    /// </summary>
    public string Priority { get; set; } = "Medium";

    /// <summary>
    /// Resolved workspace member user ID for the assignee, or null if not specified.
    /// </summary>
    public string? AssigneeId { get; set; }

    /// <summary>
    /// Display name of the resolved assignee for the review card.
    /// </summary>
    public string? AssigneeName { get; set; }

    /// <summary>
    /// Resolved UTC due date, or null if not mentioned.
    /// </summary>
    public DateTime? DueDate { get; set; }

    /// <summary>
    /// Warnings for fields that could not be confidently extracted.
    /// </summary>
    public List<string> Warnings { get; set; } = [];
}
