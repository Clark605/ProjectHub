using System;
using System.Collections.Generic;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Moq;
using ProjectHub.Api.Controllers;
using ProjectHub.Api.Data;
using StackExchange.Redis;
using Xunit;

namespace ProjectHub.Api.Tests;

public class HealthControllerTests
{
    private AppDbContext CreateInMemoryDbContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new AppDbContext(options);
    }

    private static JsonElement ToJsonElement(object? value)
    {
        var json = JsonSerializer.Serialize(value);
        return JsonDocument.Parse(json).RootElement;
    }

    [Fact]
    public async System.Threading.Tasks.Task GetHealth_ReturnsDegraded_WhenRedisConfiguredButDisconnected()
    {
        using var context = CreateInMemoryDbContext();

        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                { "ConnectionStrings:Redis", "localhost:6379" }
            })
            .Build();

        var mockRedis = new Mock<IConnectionMultiplexer>();
        mockRedis.Setup(r => r.IsConnected).Returns(false);

        var controller = new HealthController(context, configuration, mockRedis.Object);

        var result = await controller.GetHealth();

        var okResult = Assert.IsType<OkObjectResult>(result);
        Assert.Equal(StatusCodes.Status200OK, okResult.StatusCode);

        var doc = ToJsonElement(okResult.Value);
        Assert.Equal("Degraded", doc.GetProperty("status").GetString());
        Assert.Equal("Degraded (L1 Fallback)", doc.GetProperty("components").GetProperty("redis").GetString());
        Assert.Equal("Connected", doc.GetProperty("components").GetProperty("database").GetString());
    }

    [Fact]
    public async System.Threading.Tasks.Task GetHealth_ReturnsHealthy_WhenRedisConnected()
    {
        using var context = CreateInMemoryDbContext();

        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                { "ConnectionStrings:Redis", "localhost:6379" }
            })
            .Build();

        var mockRedis = new Mock<IConnectionMultiplexer>();
        mockRedis.Setup(r => r.IsConnected).Returns(true);

        var controller = new HealthController(context, configuration, mockRedis.Object);

        var result = await controller.GetHealth();

        var okResult = Assert.IsType<OkObjectResult>(result);
        Assert.Equal(StatusCodes.Status200OK, okResult.StatusCode);

        var doc = ToJsonElement(okResult.Value);
        Assert.Equal("Healthy", doc.GetProperty("status").GetString());
        Assert.Equal("Connected", doc.GetProperty("components").GetProperty("redis").GetString());
    }

    [Fact]
    public async System.Threading.Tasks.Task GetHealth_ReturnsHealthy_WhenRedisNotConfigured()
    {
        using var context = CreateInMemoryDbContext();

        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>())
            .Build();

        var controller = new HealthController(context, configuration, null);

        var result = await controller.GetHealth();

        var okResult = Assert.IsType<OkObjectResult>(result);
        var doc = ToJsonElement(okResult.Value);
        Assert.Equal("Healthy", doc.GetProperty("status").GetString());
        Assert.Equal("NotConfigured", doc.GetProperty("components").GetProperty("redis").GetString());
    }
}

