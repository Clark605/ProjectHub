using System.ComponentModel.DataAnnotations;

namespace ProjectHub.Api.DTOs.AuthDtos;

public class LogoutDto
{
    [Required]
    public string RefreshToken { get; set; } = null!;
}
