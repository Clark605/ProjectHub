using FluentValidation;
using ProjectHub.Api.Models;

namespace ProjectHub.Api.DTOs.TaskDtos;

public class UpdateTaskStatusDtoValidator : AbstractValidator<UpdateTaskStatusDto>
{
    public UpdateTaskStatusDtoValidator()
    {
        RuleFor(x => x.Status)
            .NotEmpty().WithMessage("Task status is required.")
            .IsEnumName(typeof(TaskItemStatus), caseSensitive: false)
            .WithMessage("Invalid task status. Valid values: Backlog, Todo, InProgress, Review, Done.");
    }
}

