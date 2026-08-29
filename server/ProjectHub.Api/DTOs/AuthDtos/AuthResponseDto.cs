using System;
using ProjectHub.Api.Models;

namespace ProjectHub.Api.DTOs.AuthDtos;

public class AuthResponseDto
{
    public string Token { get; set; } = null!;
    public string RefreshToken { get; set; } = null!;
}
