using System;

namespace ProjectHub.Api.DTOs.TaskDtos;

public class UpdateTaskRequestDto
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Priority { get; set; } = string.Empty;
    public string? AssigneeId { get; set; }
    public DateTime? DueDate { get; set; }
}

