using Microsoft.AspNetCore.Mvc;
using ProjectHub.Api.Data;

namespace ProjectHub.Api.Controllers;

[ApiController]
[Route("api/v1/health")]
public class HealthController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IConfiguration _configuration;
    private static readonly DateTime _startTime = DateTime.UtcNow;

    public HealthController(AppDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    [HttpGet]
    public async Task<IActionResult> GetHealth()
    {
        var dbConnected = false;
        try
        {
            dbConnected = await _context.Database.CanConnectAsync();
        }
        catch
        {
            dbConnected = false;
        }

        var redisConfigured = !string.IsNullOrWhiteSpace(_configuration.GetConnectionString("Redis"));
        var redisStatus = redisConfigured ? "Configured" : "NotConfigured";

        var uptime = DateTime.UtcNow - _startTime;
        var overallStatus = dbConnected ? "Healthy" : "Degraded";

        return Ok(new
        {
            status = overallStatus,
            database = dbConnected ? "Connected" : "Disconnected",
            redis = redisStatus,
            uptime = uptime.ToString(@"d\.hh\:mm\:ss"),
            timestamp = DateTime.UtcNow
        });
    }
}
