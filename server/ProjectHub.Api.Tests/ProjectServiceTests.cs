using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Hybrid;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Moq;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.ProjectDtos;
using ProjectHub.Api.Exceptions;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services;
using ProjectHub.Api.Services.Interfaces;
using Xunit;
using Task = System.Threading.Tasks.Task;

namespace ProjectHub.Api.Tests;

public class ProjectServiceTests
{
    private AppDbContext CreateInMemoryDbContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new AppDbContext(options);
    }

    private static Mock<UserManager<AppUser>> CreateMockUserManager()
    {
        var store = new Mock<IUserStore<AppUser>>();
        return new Mock<UserManager<AppUser>>(store.Object, null!, null!, null!, null!, null!, null!, null!, null!);
    }

    private ProjectService CreateService(AppDbContext context, Mock<UserManager<AppUser>>? userManagerMock = null, Mock<IActivityLogger>? activityLoggerMock = null)
    {
        var userManager = userManagerMock ?? CreateMockUserManager();

        var services = new ServiceCollection();
#pragma warning disable EXTEXP0018
        services.AddHybridCache();
#pragma warning restore EXTEXP0018
        var cache = services.BuildServiceProvider().GetRequiredService<HybridCache>();

        var mockActivityLogger = activityLoggerMock ?? new Mock<IActivityLogger>();
        var mockLogger = new Mock<ILogger<ProjectService>>();

        return new ProjectService(
            context,
            userManager.Object,
            cache,
            mockActivityLogger.Object,
            mockLogger.Object);
    }

    [Fact]
    public async Task DeleteProjectAsync_AsOwner_DeletesProjectSuccessfully()
    {
        using var context = CreateInMemoryDbContext();
        var mockActivityLogger = new Mock<IActivityLogger>();
        var service = CreateService(context, activityLoggerMock: mockActivityLogger);

        var workspace = new WorkSpace { Id = 1, Name = "Workspace" };
        var member = new WorkspaceMember { Workspace = workspace, UserId = "user-1", Role = "Owner" };
        var project = new Project
        {
            Id = 10,
            WorkspaceId = 1,
            Name = "Project Alpha",
            CreatedBy = "user-2",
            Status = "Active"
        };
        var activity = new ActivityEvent
        {
            Id = 100,
            WorkspaceId = 1,
            ProjectId = 10,
            ActorId = "user-1",
            ActorName = "User 1",
            EventType = ActivityEventType.ProjectCreated
        };

        context.WorkSpaces.Add(workspace);
        context.WorkspaceMembers.Add(member);
        context.Projects.Add(project);
        context.ActivityEvents.Add(activity);
        await context.SaveChangesAsync();

        await service.DeleteProjectAsync("user-1", 10);

        var deleted = await context.Projects.FindAsync(10);
        Assert.Null(deleted);

        mockActivityLogger.Verify(
            a => a.LogAsync(
                1,
                "user-1",
                It.IsAny<string>(),
                ActivityEventType.ProjectDeleted,
                null,
                null,
                It.IsAny<object?>()),
            Times.Once);
    }

    [Fact]
    public async Task DeleteProjectAsync_NonMember_ThrowsKeyNotFoundException()
    {
        using var context = CreateInMemoryDbContext();
        var service = CreateService(context);

        var workspace = new WorkSpace { Id = 1, Name = "Workspace" };
        var project = new Project
        {
            Id = 10,
            WorkspaceId = 1,
            Name = "Project Alpha",
            CreatedBy = "user-1",
            Status = "Active"
        };

        context.WorkSpaces.Add(workspace);
        context.Projects.Add(project);
        await context.SaveChangesAsync();

        await Assert.ThrowsAsync<KeyNotFoundException>(() => service.DeleteProjectAsync("user-2", 10));
    }

    [Fact]
    public async Task DeleteProjectAsync_NonOwnerNonCreator_ThrowsForbiddenException()
    {
        using var context = CreateInMemoryDbContext();
        var service = CreateService(context);

        var workspace = new WorkSpace { Id = 1, Name = "Workspace" };
        var member = new WorkspaceMember { Workspace = workspace, UserId = "user-2", Role = "Member" };
        var project = new Project
        {
            Id = 10,
            WorkspaceId = 1,
            Name = "Project Alpha",
            CreatedBy = "user-1",
            Status = "Active"
        };

        context.WorkSpaces.Add(workspace);
        context.WorkspaceMembers.Add(member);
        context.Projects.Add(project);
        await context.SaveChangesAsync();

        await Assert.ThrowsAsync<ForbiddenException>(() => service.DeleteProjectAsync("user-2", 10));
    }
}
