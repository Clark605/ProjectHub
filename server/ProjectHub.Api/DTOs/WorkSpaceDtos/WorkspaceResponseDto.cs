using System;

namespace ProjectHub.Api.DTOs.WorkSpaceDtos;

public class WorkspaceResponseDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string AccentColor { get; set; } = Models.AccentColors.Default;
    public WorkspaceMembershipDto? Membership { get; set; }
}
