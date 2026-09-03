namespace ProjectHub.Api.DTOs.WorkSpaceDtos;

public record WorkspaceMembershipDto(
    string Role,
    DateTime JoinedAt
);

