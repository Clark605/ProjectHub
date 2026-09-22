using FluentValidation;
using ProjectHub.Api.Models;

namespace ProjectHub.Api.DTOs.WorkSpaceDtos;

public class UpdateMemberRoleDtoValidator : AbstractValidator<UpdateMemberRoleDto>
{
    public UpdateMemberRoleDtoValidator()
    {
        RuleFor(x => x.Role)
            .NotEmpty().WithMessage("Role is required.")
            .IsEnumName(typeof(WorkspaceRoles), caseSensitive: false)
            .WithMessage("Invalid workspace role. Valid values: Owner, Member.");
    }
}

