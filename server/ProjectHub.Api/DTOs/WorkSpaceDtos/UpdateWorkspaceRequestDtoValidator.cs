using FluentValidation;
using ProjectHub.Api.Models;

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

        RuleFor(x => x.AccentColor)
            .NotEmpty().WithMessage("Accent color is required.")
            .Must(AccentColors.IsValid)
            .WithMessage("Accent color must be one of the supported values.");
    }
}

