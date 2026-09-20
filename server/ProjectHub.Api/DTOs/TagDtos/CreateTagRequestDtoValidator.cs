using FluentValidation;

namespace ProjectHub.Api.DTOs.TagDtos;

public class CreateTagRequestDtoValidator : AbstractValidator<CreateTagRequestDto>
{
    public CreateTagRequestDtoValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Tag name is required.")
            .MaximumLength(30).WithMessage("Tag name cannot exceed 30 characters.");
    }
}

