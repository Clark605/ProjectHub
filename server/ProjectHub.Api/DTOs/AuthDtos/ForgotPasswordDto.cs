using System.ComponentModel.DataAnnotations;

namespace ProjectHub.Api.DTOs.AuthDtos;

public class ForgotPasswordDto
{
    [Required]
    [EmailAddress]
    public string Email { get; set; } = null!;
}
