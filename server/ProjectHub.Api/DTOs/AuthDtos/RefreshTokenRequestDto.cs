using System.ComponentModel.DataAnnotations;

namespace ProjectHub.Api.DTOs.AuthDtos;

public class RefreshTokenRequestDto
{
    [Required]
    public string RefreshToken { get; set; } = null!;
}
