using System.ComponentModel.DataAnnotations;

namespace ProjectHub.Api.DTOs.AuthDtos;

public class ExternalLoginRequestDto
{
    [Required]
    public string Provider { get; set; } = string.Empty;

    public string? IdToken { get; set; }

    public string? AccessToken { get; set; }
    
    public string? Code { get; set; }

    public string? RedirectUri { get; set; }
}
