using ProjectHub.Api.Services.Interfaces;

namespace ProjectHub.Api.Services;

public class DevEmailSender : IEmailSender
{
    private readonly ILogger<DevEmailSender> _logger;

    public DevEmailSender(ILogger<DevEmailSender> logger)
    {
        _logger = logger;
    }

    public Task SendPasswordResetEmailAsync(string toEmail, string resetToken, string? resetLink = null)
    {
        var separator = new string('=', 60);
        var message = $"""

{separator}
[DEV EMAIL SENDER] Password Reset Dispatch
Recipient:   {toEmail}
Reset Token: {resetToken}
Reset Link:  {resetLink ?? "N/A"}
Timestamp:   {DateTime.UtcNow:yyyy-MM-dd HH:mm:ss} UTC
{separator}
""";

        _logger.LogInformation("{EmailMessage}", message);
        Console.WriteLine(message);

        return Task.CompletedTask;
    }
}
