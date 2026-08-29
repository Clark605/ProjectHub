using FluentValidation;

namespace ProjectHub.Api.DTOs.WorkSpaceDtos;

public class UpdateWorkspaceRequestDtoValidator : AbstractValidator<UpdateWorkspaceRequestDto>
{
    public UpdateWorkspaceRequestDtoValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Workspace name is required.")
            .MaximumLength(100).WithMessage("Workspace name cannot exceed 100 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Workspace description cannot exceed 500 characters.");
    }
}

