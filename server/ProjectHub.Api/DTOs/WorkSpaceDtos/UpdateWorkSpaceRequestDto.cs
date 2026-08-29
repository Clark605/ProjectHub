using System;

namespace ProjectHub.Api.DTOs.WorkSpaceDtos;

public class UpdateWorkspaceRequestDto
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
}
