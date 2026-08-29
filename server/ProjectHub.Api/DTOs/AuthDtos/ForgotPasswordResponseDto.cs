namespace ProjectHub.Api.DTOs.AuthDtos;

public class ForgotPasswordResponseDto
{
    public string Message { get; set; } = "If the account exists, a reset token has been generated.";
    public string? DevelopmentResetToken { get; set; }
}
