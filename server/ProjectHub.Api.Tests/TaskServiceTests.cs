using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Hybrid;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Moq;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.TaskDtos;
using ProjectHub.Api.Exceptions;
using ProjectHub.Api.Hubs;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services;
using ProjectHub.Api.Services.Interfaces;
using Xunit;
using TaskEntity = ProjectHub.Api.Models.Task;

namespace ProjectHub.Api.Tests;

public class TaskServiceTests
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

    private TaskService CreateService(AppDbContext context, Mock<UserManager<AppUser>>? userManagerMock = null)
    {
        var userManager = userManagerMock ?? CreateMockUserManager();

        var services = new ServiceCollection();
#pragma warning disable EXTEXP0018
        services.AddHybridCache();
#pragma warning restore EXTEXP0018
        var cache = services.BuildServiceProvider().GetRequiredService<HybridCache>();

        var mockActivityLogger = new Mock<IActivityLogger>();
        var mockHubContext = new Mock<IHubContext<WorkspaceHub>>();
        var mockClients = new Mock<IHubClients>();
        var mockClientProxy = new Mock<IClientProxy>();
        mockHubContext.Setup(h => h.Clients).Returns(mockClients.Object);
        mockClients.Setup(c => c.Group(It.IsAny<string>())).Returns(mockClientProxy.Object);

        var mockLogger = new Mock<ILogger<TaskService>>();

        return new TaskService(
            context,
            userManager.Object,
            cache,
            mockActivityLogger.Object,
            mockHubContext.Object,
            mockLogger.Object);
    }

    [Fact]
    public void Validator_RejectsMoreThanFiveDistinctTags()
    {
        var validator = new CreateTaskRequestDtoValidator();
        var request = new CreateTaskRequestDto
        {
            Title = "Valid Title",
            TagIds = [1, 2, 3, 4, 5, 6]
        };

        var result = validator.Validate(request);

        Assert.False(result.IsValid);
        Assert.Contains(result.Errors, e => e.PropertyName == "TagIds" && e.ErrorMessage.Contains("more than 5 tags"));
    }

    [Fact]
    public void Validator_AllowsFiveTagsAndDeduplicatesDuplicates()
    {
        var validator = new CreateTaskRequestDtoValidator();
        var request = new CreateTaskRequestDto
        {
            Title = "Valid Title",
            TagIds = [1, 2, 2, 3, 4, 5] // 6 elements, but 5 distinct
        };

        var result = validator.Validate(request);

        Assert.True(result.IsValid);
    }

    [Fact]
    public async System.Threading.Tasks.Task CreateTask_FailsAtomically_WhenTagsCannotBeResolved()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var project = new Project { Id = 10, WorkspaceId = 1, Name = "Project 1", CreatedBy = "user-1" };
        var user = new AppUser { Id = "user-1", Name = "Alice", UserName = "alice@test.com" };
        var tag1 = new Tag { Id = 101, WorkspaceId = 1, ProjectId = null, Name = "Bug", Color = "#EF4444" };

        context.WorkSpaces.Add(workspace);
        context.Projects.Add(project);
        context.Users.Add(user);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "user-1", Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });
        context.Tags.Add(tag1);
        await context.SaveChangesAsync();

        var service = CreateService(context);

        // Tag 999 does not exist
        var request = new CreateTaskRequestDto
        {
            Title = "Test Task",
            Description = "Test Description",
            Priority = "High",
            TagIds = [101, 999]
        };

        var ex = await Assert.ThrowsAsync<ArgumentException>(() =>
            service.CreateTaskAsync("user-1", 10, request));

        Assert.Contains("999", ex.Message);

        // Critical correctness verification: verify task was NOT persisted to DB
        var tasksCount = await context.Tasks.CountAsync();
        Assert.Equal(0, tasksCount);
    }

    [Fact]
    public async System.Threading.Tasks.Task CreateTask_CreatesTaskAndTagsAtomically()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var project = new Project { Id = 10, WorkspaceId = 1, Name = "Project 1", CreatedBy = "user-1" };
        var user = new AppUser { Id = "user-1", Name = "Alice", UserName = "alice@test.com" };
        var tag1 = new Tag { Id = 101, WorkspaceId = 1, ProjectId = null, Name = "Backend", Color = "#3B82F6" };
        var tag2 = new Tag { Id = 102, WorkspaceId = 1, ProjectId = 10, Name = "Sprint 1", Color = "#10B981" };

        context.WorkSpaces.Add(workspace);
        context.Projects.Add(project);
        context.Users.Add(user);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "user-1", Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });
        context.Tags.AddRange(tag1, tag2);
        await context.SaveChangesAsync();

        var service = CreateService(context);

        var request = new CreateTaskRequestDto
        {
            Title = "Atomically Created Task",
            Description = "All tags valid",
            Priority = "Urgent",
            TagIds = [101, 102]
        };

        var result = await service.CreateTaskAsync("user-1", 10, request);

        Assert.NotNull(result);
        Assert.Equal("Atomically Created Task", result.Title);
        Assert.Equal("Backlog", result.Status);
        Assert.Equal("Urgent", result.Priority);
        Assert.Equal(2, result.Tags.Count);

        // Check database entity directly
        var savedTask = await context.Tasks
            .Include(t => t.TaskTags)
            .FirstOrDefaultAsync(t => t.Id == result.Id);

        Assert.NotNull(savedTask);
        Assert.Equal(TaskItemStatus.Backlog, savedTask.Status);
        Assert.Equal(TaskItemPriority.Urgent, savedTask.Priority);
        Assert.Equal(2, savedTask.TaskTags.Count);
    }

    [Fact]
    public async System.Threading.Tasks.Task GetTasksByProject_ReturnsWireStringStatusAndPriority()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 1, Name = "Workspace 1" };
        var project = new Project { Id = 10, WorkspaceId = 1, Name = "Project 1", CreatedBy = "user-1" };
        var user = new AppUser { Id = "user-1", Name = "Alice", UserName = "alice@test.com" };

        context.WorkSpaces.Add(workspace);
        context.Projects.Add(project);
        context.Users.Add(user);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 1, UserId = "user-1", Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });

        context.Tasks.Add(new TaskEntity
        {
            Id = 1,
            ProjectId = 10,
            Title = "Task InProgress",
            Status = TaskItemStatus.InProgress,
            Priority = TaskItemPriority.High,
            CreatedBy = "user-1",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        });
        await context.SaveChangesAsync();

        var service = CreateService(context);

        var tasks = (await service.GetTasksByProjectAsync("user-1", 10, null, null, null)).ToList();

        Assert.Single(tasks);
        Assert.Equal("InProgress", tasks[0].Status);
        Assert.Equal("High", tasks[0].Priority);
    }
}
