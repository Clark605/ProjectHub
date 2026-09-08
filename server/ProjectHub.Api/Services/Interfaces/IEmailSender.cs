namespace ProjectHub.Api.Services.Interfaces;

public interface IEmailSender
{
    Task SendPasswordResetEmailAsync(string toEmail, string resetToken, string? resetLink = null);
}
