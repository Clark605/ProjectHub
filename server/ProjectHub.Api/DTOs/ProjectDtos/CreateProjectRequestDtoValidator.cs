using System;
using FluentValidation;

namespace ProjectHub.Api.DTOs.ProjectDtos;

public class CreateProjectRequestDtoValidator : AbstractValidator<CreateProjectRequestDto>
{
    public CreateProjectRequestDtoValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Project name is required.")
            .MaximumLength(100).WithMessage("Project name cannot exceed 100 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Project description cannot exceed 500 characters.");

        RuleFor(x => x.DueDate)
            .GreaterThan(DateTime.UtcNow).When(x => x.DueDate.HasValue)
            .WithMessage("Due date must be in the future.");
    }
}

