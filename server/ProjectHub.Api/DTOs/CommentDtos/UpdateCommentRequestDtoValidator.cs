using FluentValidation;

namespace ProjectHub.Api.DTOs.CommentDtos;

public class UpdateCommentRequestDtoValidator : AbstractValidator<UpdateCommentRequestDto>
{
    public UpdateCommentRequestDtoValidator()
    {
        RuleFor(x => x.Content)
            .NotEmpty().WithMessage("Comment content is required.")
            .MaximumLength(2000).WithMessage("Comment content cannot exceed 2000 characters.");
    }
}

