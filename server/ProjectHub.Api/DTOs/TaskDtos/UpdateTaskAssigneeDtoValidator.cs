using FluentValidation;

namespace ProjectHub.Api.DTOs.TaskDtos;

public class UpdateTaskAssigneeDtoValidator : AbstractValidator<UpdateTaskAssigneeDto>
{
    public UpdateTaskAssigneeDtoValidator()
    {
        RuleFor(x => x.AssigneeId)
            .Must(x => x == null || !string.IsNullOrWhiteSpace(x))
            .WithMessage("AssigneeId cannot be empty or whitespace.");
    }
}

