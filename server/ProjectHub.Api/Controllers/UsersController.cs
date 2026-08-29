using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Hybrid;
using ProjectHub.Api.DTOs.AuthDtos;
using ProjectHub.Api.Extensions;
using ProjectHub.Api.Models;

namespace ProjectHub.Api.Controllers;

[ApiController]
[Authorize]
[Route("users")]
public class UsersController : ControllerBase
{
    private readonly UserManager<AppUser> _userManager;
    private readonly HybridCache _cache;

    public UsersController(UserManager<AppUser> userManager, HybridCache cache)
    {
        _userManager = userManager;
        _cache = cache;
    }

    [HttpGet("me")]
    public async Task<ActionResult<UserProfileDto>> GetMe()
    {
        var userId = User.GetUserId();
        string cacheKey = $"user:{userId}:profile";

        var profile = await _cache.GetOrCreateAsync(
            cacheKey,
            async token =>
            {
                var user = await _userManager.FindByIdAsync(userId);
                if (user is null)
                {
                    return null;
                }

                return new UserProfileDto
                {
                    Name = user.Name,
                    Email = user.Email ?? string.Empty,
                    Bio = user.Bio
                };
            },
            tags: [$"user:{userId}:profile"]
        );

        if (profile is null)
        {
            return Unauthorized();
        }

        return Ok(profile);
    }

    [HttpPut("me")]
    public async Task<IActionResult> UpdateMe(UpdateProfileDto dto)
    {
        var userId = User.GetUserId();
        var user = await _userManager.FindByIdAsync(userId);
        if (user is null)
        {
            return Unauthorized();
        }

        user.Name = dto.Name;
        user.Bio = dto.Bio;

        var updateResult = await _userManager.UpdateAsync(user);
        if (!updateResult.Succeeded)
        {
            return BadRequest("Profile update failed.");
        }

        // Invalidate profile cache
        await _cache.RemoveByTagAsync($"user:{userId}:profile");

        return Ok(new UserProfileDto
        {
            Name = user.Name,
            Email = user.Email ?? string.Empty,
            Bio = user.Bio
        });
    }
}
