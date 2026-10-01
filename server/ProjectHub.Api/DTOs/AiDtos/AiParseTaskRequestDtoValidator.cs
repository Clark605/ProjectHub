using FluentValidation;

namespace ProjectHub.Api.DTOs.AiDtos;

public class AiParseTaskRequestDtoValidator : AbstractValidator<AiParseTaskRequestDto>
{
    public AiParseTaskRequestDtoValidator()
    {
        RuleFor(x => x.Text)
            .NotEmpty().WithMessage("Transcribed text is required.")
            .MaximumLength(5000).WithMessage("Transcribed text cannot exceed 5000 characters.");

        RuleFor(x => x.ProjectId)
            .GreaterThan(0).WithMessage("A valid project ID is required.");

        RuleFor(x => x.WorkspaceId)
            .GreaterThan(0).WithMessage("A valid workspace ID is required.");
    }
}
