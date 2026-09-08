using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using ProjectHub.Api.DTOs.AuthDtos;
using ProjectHub.Api.Services.Interfaces;

namespace ProjectHub.Api.Controllers;

[ApiController]
[Route("api/v1/auth")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly IWebHostEnvironment _environment;

    public AuthController(IAuthService authService, IWebHostEnvironment environment)
    {
        _authService = authService;
        _environment = environment;
    }

    [HttpPost("register")]
    [EnableRateLimiting("AuthRegisterPolicy")]
    public async Task<IActionResult> Register(RegisterDto dto)
    {
        var result = await _authService.RegisterAsync(dto);
        if (result is null)
        {
            return BadRequest("Registration failed.");
        }

        return Ok(result);
    }

    [HttpPost("login")]
    [EnableRateLimiting("AuthLoginPolicy")]
    public async Task<IActionResult> Login(LoginDto dto)
    {
        var result = await _authService.LoginAsync(dto);
        if (result is null)
        {
            return Unauthorized("Invalid credentials.");
        }

        return Ok(result);
    }

    [HttpPost("refresh")]
    public async Task<IActionResult> Refresh(RefreshTokenRequestDto dto)
    {
        var result = await _authService.RefreshTokenAsync(dto);
        if (result is null)
        {
            return Unauthorized("Invalid refresh token.");
        }

        return Ok(result);
    }

    [HttpPost("logout")]
    public async Task<IActionResult> Logout(LogoutDto dto)
    {
        var revoked = await _authService.LogoutAsync(dto);
        if (!revoked)
        {
            return NotFound("Refresh token not found.");
        }

        return Ok();
    }

    [HttpPost("forgot-password")]
    [EnableRateLimiting("AuthForgotPasswordPolicy")]
    public async Task<IActionResult> ForgotPassword(ForgotPasswordDto dto)
    {
        var resetToken = await _authService.GeneratePasswordResetTokenAsync(dto);

        // Prevent account enumeration by always returning the same baseline message.
        var response = new ForgotPasswordResponseDto();
        if (resetToken is not null)
        {
            response.DevelopmentResetToken = resetToken.DevelopmentResetToken;
        }

        return Ok(response);
    }

    [HttpPost("reset-password")]
    [EnableRateLimiting("AuthResetPasswordPolicy")]
    public async Task<IActionResult> ResetPassword(ResetPasswordDto dto)
    {
        var success = await _authService.ResetPasswordAsync(dto);
        if (!success)
        {
            return BadRequest("Password reset failed.");
        }

        return Ok();
    }
}
