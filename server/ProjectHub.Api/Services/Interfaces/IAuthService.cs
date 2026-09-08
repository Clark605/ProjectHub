using System;
using ProjectHub.Api.DTOs.AuthDtos;

namespace ProjectHub.Api.Services.Interfaces;

public interface IAuthService
{
    Task<AuthResponseDto?> RegisterAsync(RegisterDto dto);
    Task<AuthResponseDto?> LoginAsync(LoginDto dto);
    Task<AuthResponseDto?> RefreshTokenAsync(RefreshTokenRequestDto dto);
    Task<bool> LogoutAsync(LogoutDto dto);
    Task<ForgotPasswordResponseDto?> GeneratePasswordResetTokenAsync(ForgotPasswordDto dto);
    Task<bool> ResetPasswordAsync(ResetPasswordDto dto);
    Task<AuthResponseDto?> ExternalLoginAsync(ExternalLoginRequestDto dto);
}
