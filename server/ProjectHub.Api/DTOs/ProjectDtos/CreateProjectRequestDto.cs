using System;

namespace ProjectHub.Api.DTOs.ProjectDtos;

public class CreateProjectRequestDto
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public DateTime? DueDate { get; set; }
}

