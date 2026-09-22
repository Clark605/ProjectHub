using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using ProjectHub.Api.Data;
using StackExchange.Redis;

namespace ProjectHub.Api.Controllers;

[ApiController]
[Route("api/v1/health")]
public class HealthController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IConfiguration _configuration;
    private readonly IConnectionMultiplexer? _redisMultiplexer;
    private static readonly DateTime _startTime = DateTime.UtcNow;

    public HealthController(
        AppDbContext context,
        IConfiguration configuration,
        IConnectionMultiplexer? redisMultiplexer = null)
    {
        _context = context;
        _configuration = configuration;
        _redisMultiplexer = redisMultiplexer;
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
        var redisConnected = _redisMultiplexer?.IsConnected ?? false;

        var overallStatus = !dbConnected
            ? "Unhealthy"
            : (redisConfigured && !redisConnected ? "Degraded" : "Healthy");

        var uptime = DateTime.UtcNow - _startTime;

        string redisStatusDisplay;
        if (!redisConfigured)
        {
            redisStatusDisplay = "NotConfigured";
        }
        else if (redisConnected)
        {
            redisStatusDisplay = "Connected";
        }
        else
        {
            redisStatusDisplay = "Degraded (L1 Fallback)";
        }

        var response = new
        {
            status = overallStatus,
            components = new
            {
                database = dbConnected ? "Connected" : "Disconnected",
                redis = redisStatusDisplay
            },
            uptime = uptime.ToString(@"d\.hh\:mm\:ss"),
            timestamp = DateTime.UtcNow
        };

        return overallStatus == "Unhealthy"
            ? StatusCode(StatusCodes.Status503ServiceUnavailable, response)
            : Ok(response);
    }
}
