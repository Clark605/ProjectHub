using FluentValidation;
using ProjectHub.Api.Models;

namespace ProjectHub.Api.DTOs.TaskDtos;

public class UpdateTaskRequestDtoValidator : AbstractValidator<UpdateTaskRequestDto>
{
    public UpdateTaskRequestDtoValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Task title is required.")
            .MaximumLength(200).WithMessage("Task title cannot exceed 200 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(2000).WithMessage("Task description cannot exceed 2000 characters.");

        RuleFor(x => x.Priority)
            .NotEmpty().WithMessage("Task priority is required.")
            .IsEnumName(typeof(TaskItemPriority), caseSensitive: false)
            .WithMessage("Invalid task priority. Valid values: Low, Medium, High, Urgent.");
    }
}

