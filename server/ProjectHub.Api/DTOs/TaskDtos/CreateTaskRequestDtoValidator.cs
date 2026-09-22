using FluentValidation;
using ProjectHub.Api.Models;

namespace ProjectHub.Api.DTOs.TaskDtos;

public class CreateTaskRequestDtoValidator : AbstractValidator<CreateTaskRequestDto>
{
    public CreateTaskRequestDtoValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty().WithMessage("Task title is required.")
            .MaximumLength(200).WithMessage("Task title cannot exceed 200 characters.");

        RuleFor(x => x.Description)
            .MaximumLength(2000).WithMessage("Task description cannot exceed 2000 characters.");

        RuleFor(x => x.Priority)
            .IsEnumName(typeof(TaskItemPriority), caseSensitive: false)
            .When(x => !string.IsNullOrWhiteSpace(x.Priority))
            .WithMessage("Invalid task priority. Valid values: Low, Medium, High, Urgent.");

        RuleFor(x => x.TagIds)
            .Must(tags => tags == null || tags.Distinct().Count() <= 5)
            .WithMessage("A task cannot have more than 5 tags.");
    }
}

