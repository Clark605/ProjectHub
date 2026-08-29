using System;
using FluentValidation;
using ProjectHub.Api.Models;

namespace ProjectHub.Api.DTOs.ProjectDtos;

public class UpdateProjectRequestDtoValidator : AbstractValidator<UpdateProjectRequestDto>
{
    public UpdateProjectRequestDtoValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Project name is required.")
            .MaximumLength(100).WithMessage("Project name cannot exceed 100 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(500).WithMessage("Project description cannot exceed 500 characters.");

        RuleFor(x => x.Status)
            .NotEmpty().WithMessage("Project status is required.")
            .IsEnumName(typeof(ProjectStatus), caseSensitive: false)
            .WithMessage("Invalid project status. Valid values: Planning, Active, Completed, Archived.");

        RuleFor(x => x.DueDate)
            .GreaterThan(DateTime.UtcNow).When(x => x.DueDate.HasValue)
            .WithMessage("Due date must be in the future.");
    }
}

