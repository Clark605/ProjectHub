using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Moq;
using ProjectHub.Api.Data;
using ProjectHub.Api.DTOs.ActivityDtos;
using ProjectHub.Api.Models;
using ProjectHub.Api.Services;
using ProjectHub.Api.Services.Interfaces;
using Xunit;

namespace ProjectHub.Api.Tests;

public class DashboardServiceTests
{
    private static AppDbContext CreateInMemoryDbContext()
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        return new AppDbContext(options);
    }

    [Fact]
    public async System.Threading.Tasks.Task GetWorkspaceDashboardAsync_ReturnsAggregates()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 10, Name = "Dashboard WS", AccentColor = "teal" };
        var user = new AppUser { Id = "user-dash", Name = "Dash User", Email = "dash@test.com" };
        var project = new Project { Id = 101, WorkspaceId = 10, Name = "P1", Status = ProjectStatus.Active.ToString(), CreatedBy = user.Id, Creator = user };

        context.WorkSpaces.Add(workspace);
        context.Users.Add(user);
        context.Projects.Add(project);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 10, UserId = user.Id, Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });

        context.Tasks.Add(new Models.Task
        {
            Id = 1,
            ProjectId = 101,
            Project = project,
            Title = "Task 1",
            Status = TaskItemStatus.InProgress,
            Priority = TaskItemPriority.Urgent,
            AssigneeId = user.Id,
            Assignee = user,
            CreatedBy = user.Id,
            Creator = user,
            DueDate = DateTime.UtcNow.AddDays(1)
        });

        context.Tasks.Add(new Models.Task
        {
            Id = 2,
            ProjectId = 101,
            Project = project,
            Title = "Task 2",
            Status = TaskItemStatus.Done,
            Priority = TaskItemPriority.Low,
            AssigneeId = user.Id,
            Assignee = user,
            CreatedBy = user.Id,
            Creator = user,
            DueDate = DateTime.UtcNow.AddDays(-1)
        });
        await context.SaveChangesAsync();

        var mockActivityLogger = new Mock<IActivityLogger>();
        mockActivityLogger.Setup(a => a.GetWorkspaceActivitiesAsync(10, It.IsAny<int>(), null, null, null, null, null, null, true))
            .ReturnsAsync(new List<ActivityEventDto>());

        var logger = Mock.Of<ILogger<DashboardService>>();
        var service = new DashboardService(context, mockActivityLogger.Object, logger);

        var result = await service.GetWorkspaceDashboardAsync("user-dash", 10);

        Assert.Equal(1, result.ActiveProjectsCount);
        Assert.Equal(1, result.InProgressTasksCount);
        Assert.Equal(1, result.UrgentTasksCount);
        Assert.Equal(1, result.CompletedTasksCount);
        Assert.Single(result.FocusTasks);
        Assert.Equal("Task 1", result.FocusTasks[0].Title);
    }

    [Fact]
    public async System.Threading.Tasks.Task GetWorkspaceDashboardAsync_WhenUserNotMember_ThrowsKeyNotFoundException()
    {
        using var context = CreateInMemoryDbContext();
        var mockActivityLogger = new Mock<IActivityLogger>();
        var logger = Mock.Of<ILogger<DashboardService>>();
        var service = new DashboardService(context, mockActivityLogger.Object, logger);

        await Assert.ThrowsAsync<KeyNotFoundException>(() =>
            service.GetWorkspaceDashboardAsync("non-member", 999));
    }

    [Fact]
    public async System.Threading.Tasks.Task GetWorkspaceDashboardAsync_DateSemantics_CalculatesOverdueAndDueThisWeekCorrectly()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 20, Name = "Date Semantics WS", AccentColor = "violet" };
        var user = new AppUser { Id = "user-dates", Name = "Dates User", Email = "dates@test.com" };
        var project = new Project { Id = 201, WorkspaceId = 20, Name = "P2", Status = ProjectStatus.Active.ToString(), CreatedBy = user.Id, Creator = user };

        context.WorkSpaces.Add(workspace);
        context.Users.Add(user);
        context.Projects.Add(project);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 20, UserId = user.Id, Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });

        var now = DateTime.UtcNow;
        var todayUtc = now.Date;
        var diff = (7 + ((int)now.DayOfWeek - (int)DayOfWeek.Monday)) % 7;
        var startOfWeek = todayUtc.AddDays(-1 * diff);
        var endOfWeek = startOfWeek.AddDays(7);

        // Task due last week -> OVERDUE and not due this week
        context.Tasks.Add(new Models.Task
        {
            Id = 10,
            ProjectId = 201,
            Project = project,
            Title = "Overdue Task",
            Status = TaskItemStatus.Todo,
            Priority = TaskItemPriority.Medium,
            CreatedBy = user.Id,
            Creator = user,
            DueDate = startOfWeek.AddDays(-1)
        });

        // Task due today -> NOT overdue (due today is treated as on schedule), but due this week
        context.Tasks.Add(new Models.Task
        {
            Id = 11,
            ProjectId = 201,
            Project = project,
            Title = "Due Today Task",
            Status = TaskItemStatus.InProgress,
            Priority = TaskItemPriority.High,
            CreatedBy = user.Id,
            Creator = user,
            DueDate = todayUtc.AddHours(14)
        });

        // Task due next Monday (endOfWeek exact boundary) -> NOT due this week
        context.Tasks.Add(new Models.Task
        {
            Id = 12,
            ProjectId = 201,
            Project = project,
            Title = "Next Week Task",
            Status = TaskItemStatus.Todo,
            Priority = TaskItemPriority.Low,
            CreatedBy = user.Id,
            Creator = user,
            DueDate = endOfWeek
        });

        await context.SaveChangesAsync();

        var mockActivityLogger = new Mock<IActivityLogger>();
        mockActivityLogger.Setup(a => a.GetWorkspaceActivitiesAsync(20, It.IsAny<int>(), null, null, null, null, null, null, true))
            .ReturnsAsync(new List<ActivityEventDto>());

        var logger = Mock.Of<ILogger<DashboardService>>();
        var service = new DashboardService(context, mockActivityLogger.Object, logger);

        var result = await service.GetWorkspaceDashboardAsync("user-dates", 20);

        Assert.Equal(1, result.OverdueTasksCount);
        Assert.Equal(1, result.DueThisWeekTasksCount); // Only the "Due Today Task" is within [startOfWeek, endOfWeek)
    }

    [Fact]
    public async System.Threading.Tasks.Task GetWorkspaceDashboardAsync_FocusTasks_OrderedByPriorityAndDueDate()
    {
        using var context = CreateInMemoryDbContext();
        var workspace = new WorkSpace { Id = 30, Name = "Focus WS", AccentColor = "blue" };
        var user = new AppUser { Id = "user-focus", Name = "Focus User", Email = "focus@test.com" };
        var project = new Project { Id = 301, WorkspaceId = 30, Name = "P3", Status = ProjectStatus.Active.ToString(), CreatedBy = user.Id, Creator = user };

        context.WorkSpaces.Add(workspace);
        context.Users.Add(user);
        context.Projects.Add(project);
        context.WorkspaceMembers.Add(new WorkspaceMember { Id = 30, UserId = user.Id, Workspace = workspace, Role = WorkspaceRoles.Owner.ToString() });

        // Low priority, tomorrow
        context.Tasks.Add(new Models.Task
        {
            Id = 31,
            ProjectId = 301,
            Project = project,
            Title = "Low Task",
            Status = TaskItemStatus.Todo,
            Priority = TaskItemPriority.Low,
            AssigneeId = user.Id,
            Assignee = user,
            CreatedBy = user.Id,
            Creator = user,
            DueDate = DateTime.UtcNow.AddDays(1)
        });

        // Urgent priority, null DueDate
        context.Tasks.Add(new Models.Task
        {
            Id = 32,
            ProjectId = 301,
            Project = project,
            Title = "Urgent No Date Task",
            Status = TaskItemStatus.Todo,
            Priority = TaskItemPriority.Urgent,
            AssigneeId = user.Id,
            Assignee = user,
            CreatedBy = user.Id,
            Creator = user,
            DueDate = null
        });

        // Urgent priority, tomorrow DueDate
        context.Tasks.Add(new Models.Task
        {
            Id = 33,
            ProjectId = 301,
            Project = project,
            Title = "Urgent Tomorrow Task",
            Status = TaskItemStatus.InProgress,
            Priority = TaskItemPriority.Urgent,
            AssigneeId = user.Id,
            Assignee = user,
            CreatedBy = user.Id,
            Creator = user,
            DueDate = DateTime.UtcNow.AddDays(1)
        });

        // High priority, today
        context.Tasks.Add(new Models.Task
        {
            Id = 34,
            ProjectId = 301,
            Project = project,
            Title = "High Task",
            Status = TaskItemStatus.InProgress,
            Priority = TaskItemPriority.High,
            AssigneeId = user.Id,
            Assignee = user,
            CreatedBy = user.Id,
            Creator = user,
            DueDate = DateTime.UtcNow
        });

        await context.SaveChangesAsync();

        var mockActivityLogger = new Mock<IActivityLogger>();
        mockActivityLogger.Setup(a => a.GetWorkspaceActivitiesAsync(30, It.IsAny<int>(), null, null, null, null, null, null, true))
            .ReturnsAsync(new List<ActivityEventDto>());

        var logger = Mock.Of<ILogger<DashboardService>>();
        var service = new DashboardService(context, mockActivityLogger.Object, logger);

        var result = await service.GetWorkspaceDashboardAsync("user-focus", 30);

        Assert.Equal(4, result.FocusTasks.Count);
        // Priority order: Urgent > High > Low
        // For Urgent tasks: DueDate with value comes before null DueDate
        Assert.Equal("Urgent Tomorrow Task", result.FocusTasks[0].Title);
        Assert.Equal("Urgent No Date Task", result.FocusTasks[1].Title);
        Assert.Equal("High Task", result.FocusTasks[2].Title);
        Assert.Equal("Low Task", result.FocusTasks[3].Title);
    }
}
