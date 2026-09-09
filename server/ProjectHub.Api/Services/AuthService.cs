using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Google.Apis.Auth;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.AuthDtos;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services.Interfaces;

namespace ProjectHub.Api.Services;

public class AuthService : IAuthService
{
    private const int DefaultAccessTokenMinutes = 60;
    private const int RefreshTokenDays = 14;

    private readonly UserManager<AppUser> _userManager;
    private readonly AppDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly IWebHostEnvironment _environment;
    private readonly IEmailSender _emailSender;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<AuthService> _logger;

    public AuthService(
        UserManager<AppUser> userManager,
        AppDbContext context,
        IConfiguration configuration,
        IWebHostEnvironment environment,
        IEmailSender emailSender,
        IHttpClientFactory httpClientFactory,
        ILogger<AuthService> logger)
    {
        _userManager = userManager;
        _context = context;
        _configuration = configuration;
        _environment = environment;
        _emailSender = emailSender;
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public async Task<AuthResponseDto?> LoginAsync(LoginDto dto)
    {
        _logger.LogInformation("Login attempt for email: {Email}", dto.Email);
        
        var user = await _userManager.FindByEmailAsync(dto.Email);
        if (user is null)
        {
            _logger.LogWarning("Login failed - user not found for email: {Email}", dto.Email);
            return null;
        }

        var validPassword = await _userManager.CheckPasswordAsync(user, dto.Password);
        if (!validPassword)
        {
            _logger.LogWarning("Login failed - invalid password for email: {Email}", dto.Email);
            return null;
        }

        var roles = await _userManager.GetRolesAsync(user);
        var userClaims = await _userManager.GetClaimsAsync(user);

        var newRefreshToken = GenerateRefreshToken();
        var refreshEntity = BuildRefreshTokenEntity(user.Id, newRefreshToken);

        _context.RefreshTokens.Add(refreshEntity);
        await _context.SaveChangesAsync();

        _logger.LogInformation("User {UserId} logged in successfully", user.Id);

        return new AuthResponseDto
        {
            Token = GenerateJwtToken(user, roles, userClaims.ToList()),
            RefreshToken = newRefreshToken
        };
    }

    public async Task<bool> LogoutAsync(LogoutDto dto)
    {
        _logger.LogInformation("Logout attempt");
        
        var refreshTokenHash = ComputeSha256Hash(dto.RefreshToken);
        var tokenEntity = await _context.RefreshTokens
            .FirstOrDefaultAsync(x => x.TokenHash == refreshTokenHash);

        if (tokenEntity is null)
        {
            _logger.LogWarning("Logout failed - refresh token not found");
            return false;
        }

        if (tokenEntity.RevokedAt is not null)
        {
            _logger.LogInformation("Token already revoked");
            return true;
        }

        tokenEntity.RevokedAt = DateTime.UtcNow;
        tokenEntity.IsUsed = true;
        tokenEntity.RevocationReason = "Logged out";

        await _context.SaveChangesAsync();
        
        _logger.LogInformation("User logged out successfully");
        return true;
    }

    public async Task<AuthResponseDto?> RefreshTokenAsync(RefreshTokenRequestDto dto)
    {
        _logger.LogInformation("Token refresh attempt");
        
        var refreshTokenHash = ComputeSha256Hash(dto.RefreshToken);
        var tokenEntity = await _context.RefreshTokens
            .Include(x => x.User)
            .FirstOrDefaultAsync(x => x.TokenHash == refreshTokenHash);

        if (tokenEntity is null || tokenEntity.User is null)
        {
            _logger.LogWarning("Token refresh failed - invalid token");
            return null;
        }

        if (tokenEntity.IsUsed || tokenEntity.RevokedAt is not null || tokenEntity.ExpiresAt <= DateTime.UtcNow)
        {
            _logger.LogWarning("Token refresh failed - token used, revoked, or expired");
            return null;
        }

        var replacementRawToken = GenerateRefreshToken();
        var replacementEntity = BuildRefreshTokenEntity(tokenEntity.UserId, replacementRawToken);

        tokenEntity.IsUsed = true;
        tokenEntity.RevokedAt = DateTime.UtcNow;
        tokenEntity.ReplacedByTokenHash = replacementEntity.TokenHash;
        tokenEntity.RevocationReason = "Rotated";

        _context.RefreshTokens.Add(replacementEntity);

        var roles = await _userManager.GetRolesAsync(tokenEntity.User);
        var userClaims = await _userManager.GetClaimsAsync(tokenEntity.User);

        await _context.SaveChangesAsync();

        _logger.LogInformation("Token refreshed successfully for user {UserId}", tokenEntity.UserId);

        return new AuthResponseDto
        {
            Token = GenerateJwtToken(tokenEntity.User, roles, userClaims.ToList()),
            RefreshToken = replacementRawToken
        };
    }

    public async Task<AuthResponseDto?> RegisterAsync(RegisterDto dto)
    {
        _logger.LogInformation("Registration attempt for email: {Email}", dto.Email);
        
        var existingUser = await _userManager.FindByEmailAsync(dto.Email);
        if (existingUser is not null)
        {
            _logger.LogWarning("Registration failed - email already exists: {Email}", dto.Email);
            return null;
        }

        var user = new AppUser
        {
            UserName = dto.Email,
            Email = dto.Email,
            Name = dto.Name
        };
        var result = await _userManager.CreateAsync(user, dto.Password);
        if (!result.Succeeded)
        {
            _logger.LogWarning("Registration failed for email: {Email}. Errors: {Errors}", dto.Email, string.Join(", ", result.Errors.Select(e => e.Description)));
            return null;
        }

        var refreshToken = GenerateRefreshToken();
        var refreshEntity = BuildRefreshTokenEntity(user.Id, refreshToken);
        _context.RefreshTokens.Add(refreshEntity);
        await _context.SaveChangesAsync();

        _logger.LogInformation("User {UserId} registered successfully", user.Id);

        return new AuthResponseDto
        {
            Token = GenerateJwtToken(user, new List<string>(), new List<Claim>()),
            RefreshToken = refreshToken
        };
    }

    public async Task<ForgotPasswordResponseDto?> GeneratePasswordResetTokenAsync(ForgotPasswordDto dto)
    {
        _logger.LogInformation("Password reset token requested for email: {Email}", dto.Email);
        
        var user = await _userManager.FindByEmailAsync(dto.Email);
        if (user is null)
        {
            _logger.LogWarning("Password reset requested for non-existent email: {Email}", dto.Email);
            // Don't reveal if user exists for security
            return new ForgotPasswordResponseDto();
        }

        var resetToken = await _userManager.GeneratePasswordResetTokenAsync(user);
        await _emailSender.SendPasswordResetEmailAsync(user.Email!, resetToken);

        if (!_environment.IsDevelopment())
        {
            _logger.LogInformation("Password reset token generated and email dispatched for user {UserId} (not returned in production)", user.Id);
            return new ForgotPasswordResponseDto();
        }
        
        var response = new ForgotPasswordResponseDto
        {
            DevelopmentResetToken = resetToken
        };

        _logger.LogInformation("Password reset token generated for user {UserId} (development mode)", user.Id);
        return response;
    }

    public async Task<bool> ResetPasswordAsync(ResetPasswordDto dto)
    {
        _logger.LogInformation("Password reset attempt for email: {Email}", dto.Email);
        
        var user = await _userManager.FindByEmailAsync(dto.Email);
        if (user is null)
        {
            _logger.LogWarning("Password reset failed - user not found for email: {Email}", dto.Email);
            return false;
        }

        var result = await _userManager.ResetPasswordAsync(user, dto.Token, dto.NewPassword);
        if (result.Succeeded)
        {
            _logger.LogInformation("Password reset successful for user {UserId}", user.Id);
        }
        else
        {
            _logger.LogWarning("Password reset failed for user {UserId}. Errors: {Errors}", user.Id, string.Join(", ", result.Errors.Select(e => e.Description)));
        }
        
        return result.Succeeded;
    }

    public async Task<AuthResponseDto?> ExternalLoginAsync(ExternalLoginRequestDto dto)
    {
        string? verifiedEmail = null;
        string? verifiedName = null;

        var provider = dto.Provider.Trim().ToLowerInvariant();
        if (provider == "google")
        {
            if (string.IsNullOrWhiteSpace(dto.IdToken))
            {
                _logger.LogWarning("External login failed - Google IdToken is missing");
                return null;
            }

            if (_environment.IsDevelopment() && (dto.IdToken.StartsWith("dev_token:") || dto.IdToken == "mock_google_id_token"))
            {
                if (dto.IdToken == "mock_google_id_token")
                {
                    verifiedEmail = "google.user@example.com";
                    verifiedName = "Google Test User";
                }
                else
                {
                    var parts = dto.IdToken.Split(':');
                    verifiedEmail = parts.Length > 1 && !string.IsNullOrWhiteSpace(parts[1]) ? parts[1] : "dev.user@example.com";
                    verifiedName = parts.Length > 2 && !string.IsNullOrWhiteSpace(parts[2]) ? parts[2] : "Dev User";
                }
            }
            else
            {
                try
                {
                    var googleClientId = _configuration["Authentication:Google:ClientId"];
                    GoogleJsonWebSignature.ValidationSettings? settings = null;
                    if (!string.IsNullOrWhiteSpace(googleClientId))
                    {
                        settings = new GoogleJsonWebSignature.ValidationSettings
                        {
                            Audience = new[] { googleClientId }
                        };
                    }

                    var payload = await GoogleJsonWebSignature.ValidateAsync(dto.IdToken, settings);
                    verifiedEmail = payload?.Email;
                    verifiedName = payload?.Name ?? verifiedEmail;
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Google token validation failed");
                    return null;
                }
            }
        }
        else if (provider == "github")
        {
            if (string.IsNullOrWhiteSpace(dto.AccessToken))
            {
                _logger.LogWarning("External login failed - GitHub AccessToken is missing");
                return null;
            }

            try
            {
                var client = _httpClientFactory.CreateClient();
                client.DefaultRequestHeaders.UserAgent.Add(new ProductInfoHeaderValue("ProjectHub-API", "1.0"));
                client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", dto.AccessToken);

                var response = await client.GetAsync("https://api.github.com/user");
                if (!response.IsSuccessStatusCode)
                {
                    _logger.LogWarning("GitHub user lookup failed with status: {StatusCode}", response.StatusCode);
                    return null;
                }

                var content = await response.Content.ReadAsStringAsync();
                using var doc = JsonDocument.Parse(content);
                var root = doc.RootElement;

                if (root.TryGetProperty("email", out var emailProp) && emailProp.ValueKind == JsonValueKind.String)
                {
                    verifiedEmail = emailProp.GetString();
                }

                if (root.TryGetProperty("name", out var nameProp) && nameProp.ValueKind == JsonValueKind.String && !string.IsNullOrWhiteSpace(nameProp.GetString()))
                {
                    verifiedName = nameProp.GetString();
                }
                else if (root.TryGetProperty("login", out var loginProp) && loginProp.ValueKind == JsonValueKind.String)
                {
                    verifiedName = loginProp.GetString();
                }

                // If email is private on GitHub profile, fetch from /user/emails
                if (string.IsNullOrWhiteSpace(verifiedEmail))
                {
                    var emailsResponse = await client.GetAsync("https://api.github.com/user/emails");
                    if (emailsResponse.IsSuccessStatusCode)
                    {
                        var emailsContent = await emailsResponse.Content.ReadAsStringAsync();
                        using var emailsDoc = JsonDocument.Parse(emailsContent);
                        foreach (var item in emailsDoc.RootElement.EnumerateArray())
                        {
                            var isPrimary = item.TryGetProperty("primary", out var p) && p.GetBoolean();
                            var isVerified = item.TryGetProperty("verified", out var v) && v.GetBoolean();
                            if (isPrimary && isVerified && item.TryGetProperty("email", out var e))
                            {
                                verifiedEmail = e.GetString();
                                break;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "GitHub OAuth lookup failed");
                return null;
            }
        }
        else
        {
            _logger.LogWarning("Unsupported external login provider: {Provider}", dto.Provider);
            return null;
        }

        if (string.IsNullOrWhiteSpace(verifiedEmail))
        {
            _logger.LogWarning("External login failed - could not resolve verified email for provider: {Provider}", dto.Provider);
            return null;
        }

        var user = await _userManager.FindByEmailAsync(verifiedEmail);
        if (user is null)
        {
            user = new AppUser
            {
                UserName = verifiedEmail,
                Email = verifiedEmail,
                Name = verifiedName ?? verifiedEmail,
                EmailConfirmed = true
            };

            var createResult = await _userManager.CreateAsync(user);
            if (!createResult.Succeeded)
            {
                _logger.LogWarning("Failed to create external user {Email}. Errors: {Errors}", verifiedEmail, string.Join(", ", createResult.Errors.Select(e => e.Description)));
                return null;
            }
        }

        var refreshToken = GenerateRefreshToken();
        var refreshEntity = BuildRefreshTokenEntity(user.Id, refreshToken);
        _context.RefreshTokens.Add(refreshEntity);
        await _context.SaveChangesAsync();

        var roles = await _userManager.GetRolesAsync(user);
        var userClaims = await _userManager.GetClaimsAsync(user);

        _logger.LogInformation("External login successful for user {UserId} via provider {Provider}", user.Id, dto.Provider);

        return new AuthResponseDto
        {
            Token = GenerateJwtToken(user, roles, userClaims.ToList()),
            RefreshToken = refreshToken
        };
    }

    private string GenerateJwtToken(AppUser user, IList<string> roles, List<Claim> claims)
    {
        var key = _configuration["Jwt:Key"];
        var issuer = _configuration["Jwt:Issuer"];
        var audience = _configuration["Jwt:Audience"];

        if (string.IsNullOrWhiteSpace(key) || string.IsNullOrWhiteSpace(issuer) || string.IsNullOrWhiteSpace(audience))
        {
            throw new InvalidOperationException("JWT settings are missing. Configure Jwt:Key, Jwt:Issuer and Jwt:Audience.");
        }

        var signingKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
        var credentials = new SigningCredentials(signingKey, SecurityAlgorithms.HmacSha256);

        var jwtClaims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, user.Id),
            new(JwtRegisteredClaimNames.Sub, user.Id),
            new(JwtRegisteredClaimNames.Email, user.Email ?? string.Empty),
            new(ClaimTypes.Name, user.Name),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        jwtClaims.AddRange(claims);
        jwtClaims.AddRange(roles.Select(role => new Claim(ClaimTypes.Role, role)));

        var accessTokenMinutes = _configuration.GetValue<int>("Jwt:AccessTokenExpirationMinutes", DefaultAccessTokenMinutes);
        if (accessTokenMinutes <= 0)
        {
            accessTokenMinutes = DefaultAccessTokenMinutes;
        }

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: jwtClaims,
            expires: DateTime.UtcNow.AddMinutes(accessTokenMinutes),
            signingCredentials: credentials);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private string GenerateRefreshToken()
    {
        var randomBytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(randomBytes);
    }

    private RefreshToken BuildRefreshTokenEntity(string userId, string rawRefreshToken)
    {
        return new RefreshToken
        {
            UserId = userId,
            TokenHash = ComputeSha256Hash(rawRefreshToken),
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddDays(RefreshTokenDays),
            IsUsed = false
        };
    }

    private static string ComputeSha256Hash(string input)
    {
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(input));
        return Convert.ToHexString(bytes);
    }
}
