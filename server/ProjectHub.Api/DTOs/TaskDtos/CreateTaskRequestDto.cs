using System;

namespace ProjectHub.Api.DTOs.TaskDtos;

public class CreateTaskRequestDto
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string? Priority { get; set; }
    public string? AssigneeId { get; set; }
    public DateTime? DueDate { get; set; }
    public List<int>? TagIds { get; set; }
}

